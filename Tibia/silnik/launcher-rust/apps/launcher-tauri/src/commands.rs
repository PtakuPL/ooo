//! LR-032: Tauri command handlers — thin wrappers wokół launcher-core.
//!
//! Każda komenda:
//! 1. Pobiera stan z `AppState`.
//! 2. Deleguje do launcher-core / launcher-api.
//! 3. Zwraca DTO (nigdy surowe struktury).

use tauri::State;
use semver::Version;
use std::collections::BTreeSet;
use std::path::Path;

use common_models::api_responses::{ErrorReportRequest, LaunchTokenRequest};
use common_models::dto::*;
use common_models::installed_state::InstalledState;
use common_models::manifest::NormalizedManifest;

use launcher_api::client::{ApiClient, ApiClientConfig, ManifestFetchResult};
use launcher_core::file_index::LocalFileIndex;
use launcher_core::integrity::compute_files_hash;
use launcher_core::manifest_signature::{
    verify_manifest_signature, SignatureConfig, SignaturePolicy,
};
use launcher_core::patcher::{self, PatchContext};
use launcher_core::planner::build_update_plan;
use launcher_core::process_runner::{launch_client, LaunchConfig};
use launcher_core::repair::diagnose_installation;
use launcher_core::serverlist_sync;
use launcher_core::state as core_state;

use crate::state::AppState;

// ─────────────────────────────────────────────
// Helper: buduje SignatureConfig z klucza publicznego
// ─────────────────────────────────────────────

fn build_signature_config(public_key_hex: &Option<String>, require_signature: bool) -> SignatureConfig {
    if require_signature {
        return SignatureConfig {
            policy: SignaturePolicy::Require,
            public_key_hex: public_key_hex.clone(),
        };
    }

    match public_key_hex {
        Some(key) if !key.is_empty() => SignatureConfig {
            policy: SignaturePolicy::WarnIfMissing,
            public_key_hex: Some(key.clone()),
        },
        _ => SignatureConfig::default(), // Ignore
    }
}

fn is_bootstrap_install(installed: Option<&InstalledState>) -> bool {
    match installed {
        None => true,
        Some(state) => {
            state.current_manifest_version.is_none() || state.current_files_hash.is_none()
        }
    }
}

fn load_installed_state_or_none(launcher_data: &Path) -> Option<InstalledState> {
    let state_path = launcher_data.join("installed_state.json");
    core_state::load_state(&state_path).ok()
}

fn enforce_manifest_files_hash(
    manifest: &NormalizedManifest,
    files_hash: &str,
    require_expected: bool,
) -> Result<(), String> {
    let expected = manifest.files_hash_expected.as_deref().unwrap_or("").trim();
    if expected.is_empty() {
        if require_expected {
            return Err("LCH_BOOTSTRAP_FILES_HASH_EXPECTED_MISSING".to_string());
        }
        return Ok(());
    }

    if !expected.eq_ignore_ascii_case(files_hash) {
        return Err(format!(
            "LCH_FILES_HASH_MISMATCH: expected={} actual={}",
            expected, files_hash
        ));
    }

    Ok(())
}

/// Weryfikuje podpis manifestu i loguje wynik. Zwraca błąd tylko przy policy=Require.
fn verify_fetched_manifest(
    result: &ManifestFetchResult,
    config: &SignatureConfig,
) -> Result<(), String> {
    let verify =
        verify_manifest_signature(&result.raw_json, result.signature_hex.as_deref(), config);
    match verify {
        Ok(res) => {
            tracing::info!("Weryfikacja podpisu manifestu: {}", res.message);
            Ok(())
        }
        Err(e) => {
            tracing::warn!("Błąd weryfikacji podpisu manifestu: {e}");
            if config.policy == SignaturePolicy::Require {
                Err(format!("LCH_MANIFEST_SIGNATURE_FAILED: {e}"))
            } else {
                Ok(()) // WarnIfMissing — kontynuuj
            }
        }
    }
}

fn parse_semver_relaxed(input: &str) -> Result<Version, String> {
    let trimmed = input.trim().trim_start_matches(['v', 'V']);
    if trimmed.is_empty() {
        return Err("empty version".to_string());
    }

    let parts: Vec<&str> = trimmed.split('.').collect();
    let normalized = match parts.len() {
        2 => format!("{}.{}.0", parts[0], parts[1]),
        3 => trimmed.to_string(),
        _ => {
            return Err(format!("unsupported semver format: '{input}'"));
        }
    };

    Version::parse(&normalized).map_err(|e| format!("invalid semver '{input}': {e}"))
}

fn enforce_manifest_launcher_compat(
    min_launcher_version: Option<&str>,
    current_launcher_version: &str,
) -> Result<(), String> {
    let Some(min_raw) = min_launcher_version else {
        return Ok(());
    };

    let min = parse_semver_relaxed(min_raw)
        .map_err(|e| format!("LCH_MANIFEST_SCHEMA_UNSUPPORTED: {e}"))?;
    let current = parse_semver_relaxed(current_launcher_version)
        .map_err(|e| format!("LCH_MANIFEST_SCHEMA_UNSUPPORTED: {e}"))?;

    if current < min {
        return Err(format!(
            "LCH_LAUNCHER_UPDATE_REQUIRED: launcher={} wymagane_min={}",
            current_launcher_version, min_raw
        ));
    }

    Ok(())
}

const PREFLIGHT_MIN_LAUNCH_FREE_BYTES: u64 = 64 * 1024 * 1024;
const PREFLIGHT_MIN_UPDATE_OVERHEAD_BYTES: u64 = 128 * 1024 * 1024;

fn ensure_path_writable(path: &Path, label: &str) -> Result<(), String> {
    std::fs::create_dir_all(path)
        .map_err(|e| format!("LCH_PREFLIGHT_NOT_WRITABLE: {} mkdir failed: {}", label, e))?;

    let probe = path.join(".write_test.tmp");
    std::fs::write(&probe, b"ok")
        .map_err(|e| format!("LCH_PREFLIGHT_NOT_WRITABLE: {} write failed: {}", label, e))?;
    std::fs::remove_file(&probe)
        .map_err(|e| format!("LCH_PREFLIGHT_NOT_WRITABLE: {} cleanup failed: {}", label, e))?;
    Ok(())
}

fn ensure_free_space(path: &Path, label: &str, required_bytes: u64) -> Result<u64, String> {
    let available = fs2::available_space(path)
        .map_err(|e| format!("LCH_PREFLIGHT_SPACE_CHECK_FAILED: {}: {}", label, e))?;
    if available < required_bytes {
        return Err(format!(
            "LCH_PREFLIGHT_INSUFFICIENT_SPACE: {} available={} required={}",
            label, available, required_bytes
        ));
    }
    Ok(available)
}

fn run_preflight_for_update(
    client_dir: &Path,
    launcher_data: &Path,
    download_bytes: u64,
) -> Result<(), String> {
    ensure_path_writable(client_dir, "client_dir")?;
    ensure_path_writable(launcher_data, "launcher_data_dir")?;

    let required = download_bytes
        .saturating_mul(2)
        .saturating_add(PREFLIGHT_MIN_UPDATE_OVERHEAD_BYTES);
    let required = required.max(PREFLIGHT_MIN_UPDATE_OVERHEAD_BYTES);

    let _ = ensure_free_space(client_dir, "client_dir", required)?;
    let _ = ensure_free_space(launcher_data, "launcher_data_dir", required / 2)?;
    Ok(())
}

fn run_preflight_for_launch(client_dir: &Path, launcher_data: &Path) -> Result<(), String> {
    ensure_path_writable(client_dir, "client_dir")?;
    ensure_path_writable(launcher_data, "launcher_data_dir")?;
    let _ = ensure_free_space(client_dir, "client_dir", PREFLIGHT_MIN_LAUNCH_FREE_BYTES)?;
    Ok(())
}

// ─────────────────────────────────────────────
// LR-033: get_status — ekran statusu
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_status(state: State<'_, AppState>) -> Result<LauncherStatusDto, String> {
    let guard = state.inner.lock().map_err(|e| e.to_string())?;

    // Próba załadowania state z dysku, jeśli jeszcze nie załadowany
    let installed = match &guard.installed_state {
        Some(s) => Some(s.clone()),
        None => {
            let state_path = guard.launcher_data_dir.join("installed_state.json");
            core_state::load_state(&state_path).ok()
        }
    };

    match installed {
        Some(s) => {
            let version = s.current_manifest_version.clone().unwrap_or_default();
            if s.update_transaction.needs_recovery() {
                Ok(LauncherStatusDto::with_error(
                    guard.launcher_version.clone(),
                    guard.channel.clone(),
                    guard.language.clone(),
                    ErrorInfoDto::generic(
                        "LCH_RECOVERY_NEEDED".into(),
                        "Wykryto przerwaną aktualizację. Uruchom ponownie.".into(),
                        true,
                    ),
                ))
            } else if s.current_manifest_version.is_some() {
                Ok(LauncherStatusDto::ready(
                    guard.launcher_version.clone(),
                    guard.channel.clone(),
                    guard.language.clone(),
                    version,
                ))
            } else {
                Ok(LauncherStatusDto::checking(
                    guard.launcher_version.clone(),
                    guard.channel.clone(),
                    guard.language.clone(),
                ))
            }
        }
        None => Ok(LauncherStatusDto::checking(
            guard.launcher_version.clone(),
            guard.channel.clone(),
            guard.language.clone(),
        )),
    }
}

// ─────────────────────────────────────────────
// LR-033+034: check_for_updates — sprawdź manifest
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn check_for_updates(state: State<'_, AppState>) -> Result<UpdatePlanSummaryDto, String> {
    let (api_url, channel, client_dir, launcher_data, dev_mode, sig_key, launcher_version) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.dev_mode,
            g.signature_public_key.clone(),
            g.launcher_version.clone(),
        )
    };

    let installed = load_installed_state_or_none(&launcher_data);
    let bootstrap_mode = is_bootstrap_install(installed.as_ref());

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    // Pobierz manifest z weryfikacją podpisu (LR-053)
    let fetch_result = api
        .fetch_manifest_with_signature(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    let sig_config = build_signature_config(&sig_key, bootstrap_mode);
    verify_fetched_manifest(&fetch_result, &sig_config)?;
    let manifest = fetch_result.manifest;

    if bootstrap_mode && manifest.files_hash_expected.as_deref().unwrap_or("").trim().is_empty() {
        return Err("LCH_BOOTSTRAP_FILES_HASH_EXPECTED_MISSING".to_string());
    }

    enforce_manifest_launcher_compat(
        manifest.min_launcher_version.as_deref(),
        &launcher_version,
    )?;

    // Skanuj lokalne pliki
    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir)
        .map_err(|e| format!("Błąd skanowania: {e}"))?;

    // Wygeneruj plan
    let plan = build_update_plan(&manifest, &index).map_err(|e| format!("Błąd planowania: {e}"))?;

    tracing::info!("{}", plan.summary());

    Ok(UpdatePlanSummaryDto::from_plan(&plan))
}

// ─────────────────────────────────────────────
// LR-034: start_update — aktualizacja z progress
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn start_update(
    app: tauri::AppHandle,
    state: State<'_, AppState>,
) -> Result<UpdateProgressDto, String> {
    // Sprawdź, czy update nie jest już w trakcie
    {
        let mut g = state.inner.lock().map_err(|e| e.to_string())?;
        if g.update_in_progress {
            return Err("Aktualizacja już w trakcie".into());
        }
        g.update_in_progress = true;
    }

    let result = run_update_inner(&app, &state).await;

    // Zawsze odblokuj flagę
    if let Ok(mut g) = state.inner.lock() {
        g.update_in_progress = false;
    }

    result
}

async fn run_update_inner(
    _app: &tauri::AppHandle,
    state: &State<'_, AppState>,
) -> Result<UpdateProgressDto, String> {
    let (api_url, channel, client_dir, launcher_data, launcher_version, dev_mode, sig_key) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.launcher_version.clone(),
            g.dev_mode,
            g.signature_public_key.clone(),
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url.clone(),
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;
    let state_path = launcher_data.join("installed_state.json");

    // Załaduj lub utwórz stan
    let mut installed = core_state::load_state(&state_path).unwrap_or_else(|_| {
        InstalledState::new_minimal(
            uuid::Uuid::new_v4().to_string(),
            channel.clone(),
            client_dir.display().to_string(),
            launcher_version.clone(),
            api_url.clone(),
        )
    });

    // --- Faza 1: Manifest z weryfikacją podpisu (LR-053) ---
    let fetch_result = api
        .fetch_manifest_with_signature(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    let bootstrap_mode = is_bootstrap_install(Some(&installed));

    let sig_config = build_signature_config(&sig_key, bootstrap_mode);
    verify_fetched_manifest(&fetch_result, &sig_config)?;
    let manifest = fetch_result.manifest;

    if bootstrap_mode && manifest.files_hash_expected.as_deref().unwrap_or("").trim().is_empty() {
        return Err("LCH_BOOTSTRAP_FILES_HASH_EXPECTED_MISSING".to_string());
    }

    enforce_manifest_launcher_compat(
        manifest.min_launcher_version.as_deref(),
        &launcher_version,
    )?;

    // --- Faza 2: Skan ---
    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir)
        .map_err(|e| format!("Błąd skanowania: {e}"))?;

    let plan = build_update_plan(&manifest, &index).map_err(|e| format!("Błąd planowania: {e}"))?;

    run_preflight_for_update(&client_dir, &launcher_data, plan.total_download_bytes)?;

    if plan.is_up_to_date {
        let files_hash = compute_files_hash(&manifest, &client_dir)
            .map_err(|e| format!("LCH_FILES_HASH_COMPUTE_FAILED: {e}"))?;
        enforce_manifest_files_hash(&manifest, &files_hash, bootstrap_mode)?;

        let now = chrono_utc_now();
        installed.mark_success(
            manifest.version.clone(),
            manifest.manifest_id.clone(),
            files_hash,
            now,
        );
        core_state::save_state(&installed, &state_path)
            .map_err(|e| format!("Błąd zapisu state: {e}"))?;

        return Ok(UpdateProgressDto {
            stage: UpdateStage::Done,
            current_file: None,
            files_done: 0,
            files_total: 0,
            bytes_done: 0,
            bytes_total: 0,
            percent: 100,
            eta_seconds: None,
        });
    }

    // --- Faza 3: Pobieranie i staging ---
    let tx_id = uuid::Uuid::new_v4().to_string();
    let ctx = PatchContext::new(&client_dir, &launcher_data, &tx_id);

    ctx.init_dirs()
        .map_err(|e| format!("Błąd init dirs: {e}"))?;

    installed.update_transaction.begin(
        tx_id.clone(),
        manifest.version.clone(),
        manifest.manifest_id.clone(),
        chrono_utc_now(),
        ctx.staging_dir.display().to_string(),
    );
    core_state::save_state(&installed, &state_path)
        .map_err(|e| format!("Błąd zapisu state: {e}"))?;

    let total_files = plan.to_download.len() as u32;
    let total_bytes = plan.total_download_bytes;

    // TODO: W przyszłości emitować eventy Tauri do UI per-plik:
    // app.emit("update-progress", &progress_dto);

    let mut staged_paths: Vec<String> = Vec::new();

    for (i, file_action) in plan.to_download.iter().enumerate() {
        let data = api
            .download_file(&file_action.url)
            .await
            .map_err(|e| format!("LCH_DOWNLOAD_FAILED: {} — {e}", file_action.path))?;

        patcher::stage_file(&ctx, &file_action.path, &data, &file_action.expected_sha256)
            .map_err(|e| format!("LCH_FILE_HASH_MISMATCH: {} — {e}", file_action.path))?;

        staged_paths.push(file_action.path.clone());

        tracing::info!("Pobrano [{}/{}]: {}", i + 1, total_files, file_action.path);
    }

    // --- Faza 4: Backup + Apply ---
    patcher::apply_plan(&ctx, &plan, &staged_paths, &mut installed)
        .map_err(|e| format!("LCH_PATCH_APPLY_FAILED: {e}"))?;

    // --- Faza 5: Finalizacja ---
    let files_hash = compute_files_hash(&manifest, &client_dir)
        .map_err(|e| format!("LCH_FILES_HASH_COMPUTE_FAILED: {e}"))?;
    enforce_manifest_files_hash(&manifest, &files_hash, bootstrap_mode)?;

    installed.mark_success(
        manifest.version.clone(),
        manifest.manifest_id.clone(),
        files_hash,
        chrono_utc_now(),
    );

    ctx.cleanup().ok();

    // Serverlist sync
    if !manifest.servers.is_empty() {
        let lua_path = client_dir.join("serverlist.lua");
        let json_path = client_dir.join("serverlist.json");
        serverlist_sync::sync_serverlist(&manifest.servers, &lua_path).ok();
        serverlist_sync::sync_serverlist_json(&manifest.servers, &json_path).ok();
    }

    core_state::save_state(&installed, &state_path)
        .map_err(|e| format!("Błąd zapisu state: {e}"))?;

    // Zapisz stan w pamięci
    if let Ok(mut g) = state.inner.lock() {
        g.installed_state = Some(installed);
    }

    Ok(UpdateProgressDto {
        stage: UpdateStage::Done,
        current_file: None,
        files_done: total_files,
        files_total: total_files,
        bytes_done: total_bytes,
        bytes_total: total_bytes,
        percent: 100,
        eta_seconds: None,
    })
}

// ─────────────────────────────────────────────
// LR-085: pre_launch_check — weryfikacja plików krytycznych
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn pre_launch_check(state: State<'_, AppState>) -> Result<PreLaunchCheckDto, String> {
    let (api_url, channel, client_dir, launcher_data, dev_mode, sig_key, launcher_version) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.dev_mode,
            g.signature_public_key.clone(),
            g.launcher_version.clone(),
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let fetch_result = api
        .fetch_manifest_with_signature(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path).ok();
    let bootstrap_mode = is_bootstrap_install(installed.as_ref());

    let sig_config = build_signature_config(&sig_key, bootstrap_mode);
    verify_fetched_manifest(&fetch_result, &sig_config)?;
    let manifest = fetch_result.manifest;

    enforce_manifest_launcher_compat(
        manifest.min_launcher_version.as_deref(),
        &launcher_version,
    )?;

    if manifest.critical_files.is_empty() {
        return Ok(PreLaunchCheckDto {
            passed: true,
            ok_count: 0,
            modified_files: Vec::new(),
            missing_files: Vec::new(),
            error_files: Vec::new(),
        });
    }

    let report =
        launcher_core::integrity::verify_critical_files(&manifest.critical_files, &client_dir);

    tracing::info!(
        "Pre-launch check: passed={}, ok={}, modified={}, missing={}",
        report.passed,
        report.ok_count,
        report.modified.len(),
        report.missing.len()
    );

    Ok(PreLaunchCheckDto {
        passed: report.passed,
        ok_count: report.ok_count,
        modified_files: report.modified,
        missing_files: report.missing,
        error_files: report.errors,
    })
}

#[tauri::command]
pub async fn repair_tampered_critical_files(
    app: tauri::AppHandle,
    state: State<'_, AppState>,
) -> Result<UpdateProgressDto, String> {
    {
        let mut g = state.inner.lock().map_err(|e| e.to_string())?;
        if g.update_in_progress {
            return Err("Aktualizacja już w trakcie".into());
        }
        g.update_in_progress = true;
    }

    let result = repair_tampered_critical_files_inner(&app, &state).await;

    if let Ok(mut g) = state.inner.lock() {
        g.update_in_progress = false;
    }

    result
}

async fn repair_tampered_critical_files_inner(
    app: &tauri::AppHandle,
    state: &State<'_, AppState>,
) -> Result<UpdateProgressDto, String> {
    let (api_url, channel, client_dir, launcher_data, launcher_version, dev_mode, sig_key) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.launcher_version.clone(),
            g.dev_mode,
            g.signature_public_key.clone(),
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let fetch_result = api
        .fetch_manifest_with_signature(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path).ok();
    let bootstrap_mode = is_bootstrap_install(installed.as_ref());

    let sig_config = build_signature_config(&sig_key, bootstrap_mode);
    verify_fetched_manifest(&fetch_result, &sig_config)?;
    let manifest = fetch_result.manifest;

    enforce_manifest_launcher_compat(
        manifest.min_launcher_version.as_deref(),
        &launcher_version,
    )?;

    if manifest.critical_files.is_empty() {
        return Ok(UpdateProgressDto {
            stage: UpdateStage::Done,
            current_file: None,
            files_done: 0,
            files_total: 0,
            bytes_done: 0,
            bytes_total: 0,
            percent: 100,
            eta_seconds: None,
        });
    }

    let report = launcher_core::integrity::verify_critical_files(&manifest.critical_files, &client_dir);
    if report.passed {
        return Ok(UpdateProgressDto {
            stage: UpdateStage::Done,
            current_file: None,
            files_done: 0,
            files_total: 0,
            bytes_done: 0,
            bytes_total: 0,
            percent: 100,
            eta_seconds: None,
        });
    }

    let mut targets = BTreeSet::new();
    for p in &report.modified {
        targets.insert(p.clone());
    }
    for err in &report.errors {
        if let Some((path, _rest)) = err.split_once(':') {
            targets.insert(path.trim().to_string());
        }
    }

    let to_quarantine: Vec<String> = targets.into_iter().collect();
    if !to_quarantine.is_empty() {
        let quarantine_root = launcher_data.join("quarantine");
        let q = launcher_core::integrity::quarantine_critical_files(
            &to_quarantine,
            &client_dir,
            &quarantine_root,
        );

        tracing::warn!(
            "Anti-tamper: moved={} failed={} quarantine_dir={}",
            q.moved_files.len(),
            q.failed_files.len(),
            q.quarantine_dir.display()
        );
        if !q.failed_files.is_empty() {
            tracing::warn!("Anti-tamper quarantine failures: {:?}", q.failed_files);
        }
    }

    // Redownload po kwarantannie przez standardowy flow aktualizacji.
    run_update_inner(app, state).await
}

// ─────────────────────────────────────────────
// LR-035: launch_game — start klienta
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn launch_game(
    state: State<'_, AppState>,
    email: Option<String>,
    password: Option<String>,
) -> Result<String, String> {
    let (api_url, channel, client_dir, launcher_data, launcher_version, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.launcher_version.clone(),
            g.dev_mode,
        )
    };

    let state_path = launcher_data.join("installed_state.json");

    run_preflight_for_launch(&client_dir, &launcher_data)?;

    let installed = core_state::load_state(&state_path)
        .map_err(|_| "Brak stanu instalacji. Uruchom najpierw aktualizację.".to_string())?;

    let files_hash = installed
        .current_files_hash
        .as_deref()
        .ok_or("Brak filesHash. Uruchom aktualizację.")?
        .to_string();

    let manifest_version = installed
        .current_manifest_version
        .as_deref()
        .unwrap_or("unknown")
        .to_string();

    // Pobierz token
    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;
    let token_req = LaunchTokenRequest {
        launcher_version: launcher_version.clone(),
        files_hash,
        channel: channel.clone(),
        manifest_version,
        nonce: None,
        challenge_response: None,
    };

    let token_resp = api
        .request_launch_token(&token_req)
        .await
        .map_err(|e| format!("LCH_TOKEN_REQUEST_FAILED: {e}"))?;

    tracing::info!(
        "Token otrzymany, wygasa za {}s",
        token_resp.expires_in_seconds
    );

    // Uruchom klienta
    let client_exe = if cfg!(windows) {
        client_dir.join("otclient.exe")
    } else {
        client_dir.join("otclient")
    };

    let mut extra_env: Vec<(String, String)> = vec![];
    if let Some(ref e) = email {
        if !e.is_empty() {
            extra_env.push(("OTC_ACCOUNT".into(), e.clone()));
        }
    }
    if let Some(ref p) = password {
        if !p.is_empty() {
            extra_env.push(("OTC_PASSWORD".into(), p.clone()));
        }
    }

    let config = LaunchConfig {
        client_exe_path: client_exe.display().to_string(),
        working_dir: client_dir.display().to_string(),
        launch_token: token_resp.token,
        channel: channel.clone(),
        extra_env,
    };

    launch_client(&config).map_err(|e| format!("LCH_CLIENT_START_FAILED: {e}"))?;

    Ok("Klient uruchomiony".into())
}

// ─────────────────────────────────────────────
// LR-036: repair_installation — diagnostyka + naprawa
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn repair_installation(
    state: State<'_, AppState>,
) -> Result<RepairDiagnosticsDto, String> {
    let (api_url, channel, client_dir, launcher_data, dev_mode, sig_key) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.launcher_data_dir.clone(),
            g.dev_mode,
            g.signature_public_key.clone(),
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let fetch_result = api
        .fetch_manifest_with_signature(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path).ok();
    let bootstrap_mode = is_bootstrap_install(installed.as_ref());

    let sig_config = build_signature_config(&sig_key, bootstrap_mode);
    verify_fetched_manifest(&fetch_result, &sig_config)?;
    let manifest = fetch_result.manifest;

    let (diag, _plan) = diagnose_installation(&manifest, &client_dir)
        .map_err(|e| format!("Błąd diagnostyki: {e}"))?;

    Ok(RepairDiagnosticsDto {
        corrupted_count: diag.corrupted_files.len() as u32,
        missing_count: diag.missing_files.len() as u32,
        ok_count: diag.ok_files.len() as u32,
        repair_download_bytes: diag.total_repair_bytes,
        corrupted_files: diag.corrupted_files,
        missing_files: diag.missing_files,
    })
}

// ─────────────────────────────────────────────
// LR-033: get_installation_info — podsumowanie stanu
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_installation_info(
    state: State<'_, AppState>,
) -> Result<InstallationSummaryDto, String> {
    let launcher_data = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        g.launcher_data_dir.clone()
    };

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path)
        .map_err(|_| "Brak pliku stanu instalacji.".to_string())?;

    Ok(InstallationSummaryDto::from_state(&installed))
}

// ─────────────────────────────────────────────
// LR-038: change_channel — zmiana kanału
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn change_channel(
    channel: String,
    language: Option<String>,
    state: State<'_, AppState>,
) -> Result<String, String> {
    let valid = ["stable", "test", "dev"];
    if !valid.contains(&channel.as_str()) {
        return Err(format!(
            "Nieprawidłowy kanał: {channel}. Dostępne: stable, test, dev"
        ));
    }

    if let Some(lang) = &language {
        if lang.trim().is_empty() {
            return Err("Nieprawidłowy język: wartość pusta".to_string());
        }
    }

    let mut g = state.inner.lock().map_err(|e| e.to_string())?;
    g.channel = channel.clone();
    g.config.channel = channel.clone();

    if let Some(lang) = language {
        g.language = lang.clone();
        g.config.language = lang;
    }

    g.config
        .validate()
        .map_err(|e| format!("Błąd walidacji configu: {e}"))?;
    g.config
        .save_to_file(&g.config_path)
        .map_err(|e| format!("Błąd zapisu launcher_config.json: {e}"))?;

    tracing::info!(
        "Zmieniono ustawienia launchera: channel={} language={} config={}",
        g.channel,
        g.language,
        g.config_path.display()
    );
    Ok(format!(
        "Ustawienia zapisane: channel={} language={}",
        g.channel, g.language
    ))
}

// ─────────────────────────────────────────────
// LR-037: export_logs — eksport logów
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn export_logs(state: State<'_, AppState>) -> Result<String, String> {
    let launcher_data = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        g.launcher_data_dir.clone()
    };

    let log_dir = launcher_data.join("logs");
    if !log_dir.exists() {
        return Err("Brak katalogu logów.".into());
    }

    // Zbierz pliki logów do archiwum tekstowego
    let export_path = launcher_data.join("launcher_logs_export.txt");
    let mut content = String::new();
    content.push_str("=== RedDaxe.pl Launcher — eksport logów ===\n\n");

    if let Ok(entries) = std::fs::read_dir(&log_dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.extension().map(|e| e == "log").unwrap_or(false) {
                content.push_str(&format!("--- {} ---\n", path.display()));
                if let Ok(text) = std::fs::read_to_string(&path) {
                    content.push_str(&text);
                    content.push('\n');
                }
            }
        }
    }

    // Dołącz installed_state.json
    let state_path = launcher_data.join("installed_state.json");
    if state_path.exists() {
        content.push_str("\n--- installed_state.json ---\n");
        if let Ok(text) = std::fs::read_to_string(&state_path) {
            content.push_str(&text);
        }
    }

    std::fs::write(&export_path, &content).map_err(|e| format!("Błąd zapisu eksportu: {e}"))?;

    Ok(export_path.display().to_string())
}

// ─────────────────────────────────────────────
// K20: build_create_character_url — launcher->WWW auto-login URL
// ─────────────────────────────────────────────

fn percent_encode_component(input: &str) -> String {
    let mut out = String::with_capacity(input.len());
    for b in input.bytes() {
        let is_unreserved = b.is_ascii_alphanumeric() || matches!(b, b'-' | b'_' | b'.' | b'~');
        if is_unreserved {
            out.push(char::from(b));
        } else {
            out.push('%');
            out.push_str(&format!("{b:02X}"));
        }
    }
    out
}

fn append_query_param(url: &str, key: &str, value: &str) -> String {
    let separator = if url.contains('?') { '&' } else { '?' };
    format!("{url}{separator}{key}={}", percent_encode_component(value))
}

#[tauri::command]
pub async fn build_create_character_url(
    state: State<'_, AppState>,
    session_key: String,
    mode: String,
) -> Result<serde_json::Value, String> {
    let safe_mode = match mode.trim().to_ascii_lowercase().as_str() {
        "classic74" => "classic74",
        "modern" => "modern",
        _ => return Err("Nieprawidłowy tryb. Dozwolone: classic74, modern".to_string()),
    };

    let trimmed_session_key = session_key.trim();
    if trimmed_session_key.is_empty() {
        return Err("Brak sessionKey launchera.".to_string());
    }
    if trimmed_session_key.len() > 256 {
        return Err("sessionKey jest zbyt długi.".to_string());
    }

    let (api_url, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (g.api_base_url.clone(), g.dev_mode)
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let sync = api
        .request_account_sync_token(trimmed_session_key, "launcher", "www")
        .await
        .map_err(|e| format!("SYNC_TOKEN_REQUEST_FAILED: {e}"))?;

    let consume_url = sync
        .consume_url
        .clone()
        .ok_or_else(|| "SYNC_TOKEN_CONSUME_URL_MISSING".to_string())?;

    let redirect = format!("/account/createcharacter?source=launcher&mode={safe_mode}");
    let final_url = append_query_param(&consume_url, "redirect", &redirect);

    Ok(serde_json::json!({
        "ok": true,
        "url": final_url,
        "mode": safe_mode,
        "syncToken": sync.sync_token,
        "expiresAt": sync.expires_at,
        "consumeUrl": consume_url
    }))
}

#[tauri::command]
pub async fn refresh_launcher_account_context(
    state: State<'_, AppState>,
    session_key: String,
) -> Result<serde_json::Value, String> {
    let trimmed_session_key = session_key.trim();
    if trimmed_session_key.is_empty() {
        return Err("Brak sessionKey launchera.".to_string());
    }
    if trimmed_session_key.len() > 256 {
        return Err("sessionKey jest zbyt długi.".to_string());
    }

    let (api_url, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (g.api_base_url.clone(), g.dev_mode)
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let ctx = api
        .fetch_account_context(trimmed_session_key)
        .await
        .map_err(|e| format!("ACCOUNT_CONTEXT_REFRESH_FAILED: {e}"))?;

    let account_name = ctx
        .get("account")
        .and_then(|a| a.get("name"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();
    let account_email = ctx
        .get("account")
        .and_then(|a| a.get("email"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .trim()
        .to_lowercase();

    let world_count = ctx
        .get("worlds")
        .and_then(|w| w.as_array())
        .map(|arr| arr.len())
        .unwrap_or(0);

    let counts_obj = ctx.get("counts").and_then(|c| c.as_object());
    let count_all = counts_obj
        .and_then(|c| c.get("all"))
        .and_then(|v| v.as_u64())
        .unwrap_or(0) as usize;
    let count_classic = counts_obj
        .and_then(|c| c.get("classic74"))
        .and_then(|v| v.as_u64())
        .unwrap_or(0) as usize;
    let count_modern = counts_obj
        .and_then(|c| c.get("modern"))
        .and_then(|v| v.as_u64())
        .unwrap_or(0) as usize;
    let count_unknown = counts_obj
        .and_then(|c| c.get("unknown"))
        .and_then(|v| v.as_u64())
        .unwrap_or(0) as usize;

    let session_game_mode = ctx
        .get("session")
        .and_then(|s| s.get("gameMode"))
        .and_then(|v| v.as_str())
        .unwrap_or("all")
        .to_string();
    let session_expires_at = ctx
        .get("session")
        .and_then(|s| s.get("expiresAt"))
        .and_then(|v| v.as_u64())
        .unwrap_or(0);

    Ok(serde_json::json!({
        "ok": true,
        "accountName": account_name,
        "email": account_email,
        "worldCount": world_count,
        "characterCount": count_all,
        "counts": {
            "all": count_all,
            "classic74": count_classic,
            "modern": count_modern,
            "unknown": count_unknown
        },
        "gameMode": session_game_mode,
        "sessionExpiresAt": session_expires_at
    }))
}

#[tauri::command]
pub async fn login_launcher_account(
    state: State<'_, AppState>,
    email: String,
    password: String,
) -> Result<serde_json::Value, String> {
    let trimmed_email = email.trim();
    if trimmed_email.is_empty() || trimmed_email.len() > 254 || !trimmed_email.contains('@') {
        return Err("Nieprawidłowy email konta.".to_string());
    }
    // API/WWW normalizują email do lowercase; launcher musi robić to samo,
    // żeby auto-login po rejestracji działał deterministycznie.
    let canonical_email = trimmed_email.to_lowercase();
    if password.is_empty() || password.len() > 512 {
        return Err("Nieprawidłowe hasło konta.".to_string());
    }

    let (api_url, channel, launcher_data, launcher_version, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.launcher_data_dir.clone(),
            g.launcher_version.clone(),
            g.dev_mode,
        )
    };

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path).map_err(|_| {
        "Brak stanu instalacji klienta. Najpierw uruchom aktualizację launchera.".to_string()
    })?;

    let files_hash = installed
        .current_files_hash
        .as_deref()
        .ok_or_else(|| "Brak filesHash klienta. Uruchom aktualizację launchera.".to_string())?
        .to_string();
    let manifest_version = installed
        .current_manifest_version
        .as_deref()
        .unwrap_or("unknown")
        .to_string();

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let launch_token = api
        .request_launch_token(&LaunchTokenRequest {
            launcher_version: launcher_version.clone(),
            files_hash,
            channel,
            manifest_version,
            nonce: None,
            challenge_response: None,
        })
        .await
        .map_err(|e| format!("ACCOUNT_LOGIN_TOKEN_FAILED: {e}"))?;

    let login_resp = api
        .login_account(&canonical_email, &password, "all", Some(&launch_token.token))
        .await
        .map_err(|e| format!("ACCOUNT_LOGIN_FAILED: {e}"))?;

    let session_key = login_resp
        .get("session")
        .and_then(|s| s.get("sessionkey"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .trim()
        .to_string();
    if session_key.is_empty() {
        return Err("ACCOUNT_LOGIN_FAILED: Brak sessionkey w odpowiedzi login.php".to_string());
    }

    let legacy_session_key = login_resp
        .get("session")
        .and_then(|s| s.get("key"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .to_string();
    let game_mode = login_resp
        .get("session")
        .and_then(|s| s.get("gameMode"))
        .and_then(|v| v.as_str())
        .unwrap_or("all")
        .to_string();
    let world_count = login_resp
        .get("playdata")
        .and_then(|p| p.get("worlds"))
        .and_then(|w| w.as_array())
        .map(|arr| arr.len())
        .unwrap_or(0);
    let character_count = login_resp
        .get("playdata")
        .and_then(|p| p.get("characters"))
        .and_then(|w| w.as_array())
        .map(|arr| arr.len())
        .unwrap_or(0);

    Ok(serde_json::json!({
        "ok": true,
        "sessionKey": session_key,
        "legacySessionKey": legacy_session_key,
        "gameMode": game_mode,
        "email": canonical_email,
        "worldCount": world_count,
        "characterCount": character_count
    }))
}

#[tauri::command]
pub async fn register_launcher_account(
    state: State<'_, AppState>,
    account_name: String,
    email: String,
    password: String,
    password_confirm: String,
) -> Result<serde_json::Value, String> {
    let trimmed_account_name = account_name.trim();
    let account_len = trimmed_account_name.chars().count();
    let account_name_valid = (3..=32).contains(&account_len)
        && trimmed_account_name
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '_');
    if !account_name_valid {
        return Err("Nieprawidłowa nazwa konta. Użyj 3-32 znaków [A-Za-z0-9_].".to_string());
    }

    let trimmed_email = email.trim();
    if trimmed_email.is_empty() || trimmed_email.len() > 254 || !trimmed_email.contains('@') {
        return Err("Nieprawidłowy email konta.".to_string());
    }
    let canonical_email = trimmed_email.to_lowercase();

    if password.len() < 6 || password.len() > 72 {
        return Err("Nieprawidłowe hasło. Użyj 6-72 znaków.".to_string());
    }
    if password != password_confirm {
        return Err("Hasła nie są identyczne.".to_string());
    }

    let (api_url, channel, launcher_data, launcher_version, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.launcher_data_dir.clone(),
            g.launcher_version.clone(),
            g.dev_mode,
        )
    };

    let state_path = launcher_data.join("installed_state.json");
    let installed = core_state::load_state(&state_path).map_err(|_| {
        "Brak stanu instalacji klienta. Najpierw uruchom aktualizację launchera.".to_string()
    })?;

    let files_hash = installed
        .current_files_hash
        .as_deref()
        .ok_or_else(|| "Brak filesHash klienta. Uruchom aktualizację launchera.".to_string())?
        .to_string();
    let manifest_version = installed
        .current_manifest_version
        .as_deref()
        .unwrap_or("unknown")
        .to_string();

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let register_resp = api
        .register_account(
            trimmed_account_name,
            &canonical_email,
            &password,
            &password_confirm,
        )
        .await
        .map_err(|e| format!("ACCOUNT_REGISTER_FAILED: {e}"))?;

    let account_id = register_resp
        .get("accountId")
        .and_then(|v| v.as_u64())
        .unwrap_or(0);
    let returned_account_name = register_resp
        .get("accountName")
        .and_then(|v| v.as_str())
        .unwrap_or(trimmed_account_name)
        .to_string();
    let returned_email = register_resp
        .get("email")
        .and_then(|v| v.as_str())
        .unwrap_or(&canonical_email)
        .trim()
        .to_lowercase();

    let launch_token = match api
        .request_launch_token(&LaunchTokenRequest {
            launcher_version: launcher_version.clone(),
            files_hash,
            channel,
            manifest_version,
            nonce: None,
            challenge_response: None,
        })
        .await
    {
        Ok(token) => token,
        Err(err) => {
            return Ok(serde_json::json!({
                "ok": true,
                "accountId": account_id,
                "accountName": returned_account_name,
                "email": returned_email,
                "autoLogin": false,
                "autoLoginError": format!("ACCOUNT_AUTOLOGIN_TOKEN_FAILED: {err}")
            }));
        }
    };

    match api
        .login_account(&returned_email, &password, "all", Some(&launch_token.token))
        .await
    {
        Ok(login_resp) => {
            let session_key = login_resp
                .get("session")
                .and_then(|s| s.get("sessionkey"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .trim()
                .to_string();

            let legacy_session_key = login_resp
                .get("session")
                .and_then(|s| s.get("key"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .to_string();
            let game_mode = login_resp
                .get("session")
                .and_then(|s| s.get("gameMode"))
                .and_then(|v| v.as_str())
                .unwrap_or("all")
                .to_string();
            let world_count = login_resp
                .get("playdata")
                .and_then(|p| p.get("worlds"))
                .and_then(|w| w.as_array())
                .map(|arr| arr.len())
                .unwrap_or(0);
            let character_count = login_resp
                .get("playdata")
                .and_then(|p| p.get("characters"))
                .and_then(|w| w.as_array())
                .map(|arr| arr.len())
                .unwrap_or(0);

            Ok(serde_json::json!({
                "ok": true,
                "accountId": account_id,
                "accountName": returned_account_name,
                "email": returned_email,
                "autoLogin": !session_key.is_empty(),
                "sessionKey": session_key,
                "legacySessionKey": legacy_session_key,
                "gameMode": game_mode,
                "worldCount": world_count,
                "characterCount": character_count
            }))
        }
        Err(err) => Ok(serde_json::json!({
            "ok": true,
            "accountId": account_id,
            "accountName": returned_account_name,
            "email": returned_email,
            "autoLogin": false,
            "autoLoginError": format!("ACCOUNT_AUTOLOGIN_FAILED: {err}")
        })),
    }
}

// ─────────────────────────────────────────────
// Helper: UTC timestamp bez zależności chrono
// ─────────────────────────────────────────────

fn chrono_utc_now() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let days = secs / 86400;
    let day_secs = secs % 86400;
    let h = day_secs / 3600;
    let m = (day_secs % 3600) / 60;
    let s = day_secs % 60;

    // Howard Hinnant's algorithm
    let z = days as i64 + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = (z - era * 146097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let mon = if mp < 10 { mp + 3 } else { mp - 9 };
    let yr = if mon <= 2 { y + 1 } else { y };

    format!("{yr:04}-{mon:02}-{d:02}T{h:02}:{m:02}:{s:02}Z")
}

// ─────────────────────────────────────────────
// LR-044: Download Center — get_installer_catalog
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_installer_catalog(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let (api_url, channel, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (
            guard.api_base_url.clone(),
            guard.channel.clone(),
            guard.dev_mode,
        )
    };

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let catalog = client
        .fetch_installer_catalog(&channel)
        .await
        .map_err(|e| format!("Błąd pobierania katalogu: {e}"))?;

    serde_json::to_value(&catalog).map_err(|e| e.to_string())
}

// ─────────────────────────────────────────────
// Faza 9.4: language packs
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_language_packs(state: State<'_, AppState>) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (guard.api_base_url.clone(), guard.dev_mode)
    };

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let packs = client
        .fetch_language_packs()
        .await
        .map_err(|e| format!("Błąd pobierania paczek językowych: {e}"))?;

    serde_json::to_value(&packs).map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn download_language_pack(
    state: State<'_, AppState>,
    locale: String,
) -> Result<serde_json::Value, String> {
    let normalized_locale = locale.trim().to_ascii_lowercase();
    if normalized_locale.is_empty() {
        return Err("Locale nie może być pusty".to_string());
    }

    let (api_url, launcher_data, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (
            guard.api_base_url.clone(),
            guard.launcher_data_dir.clone(),
            guard.dev_mode,
        )
    };

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let catalog = client
        .fetch_language_packs()
        .await
        .map_err(|e| format!("Błąd pobierania katalogu paczek: {e}"))?;

    let pack = catalog
        .available_packs
        .iter()
        .find(|p| p.locale.eq_ignore_ascii_case(&normalized_locale))
        .ok_or_else(|| {
            format!("Nie znaleziono paczki językowej dla locale '{normalized_locale}'")
        })?;

    let packs_root = launcher_data.join("i18n").join("language-packs");
    let result =
        launcher_core::language_pack_download::download_language_pack(&client, pack, &packs_root)
            .await
            .map_err(|e| format!("Instalacja paczki językowej nie powiodła się: {e}"))?;

    Ok(serde_json::json!({
      "locale": result.locale,
      "version": result.version,
      "cacheKey": result.cache_key,
      "archivePath": result.archive_path.display().to_string(),
      "installDir": result.install_dir.display().to_string(),
      "fileCount": result.file_count,
      "totalUnpackedBytes": result.total_unpacked_bytes
    }))
}

#[tauri::command]
pub async fn list_installed_language_packs(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let launcher_data = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        guard.launcher_data_dir.clone()
    };
    let packs_root = launcher_data.join("i18n").join("language-packs");

    let packs = launcher_core::language_pack_download::list_installed_packs(&packs_root)
        .map_err(|e| format!("Błąd odczytu zainstalowanych paczek: {e}"))?;

    serde_json::to_value(&packs).map_err(|e| e.to_string())
}

// ─────────────────────────────────────────────
// LR-045: download_and_verify_artifact
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn download_and_verify_artifact(
    state: State<'_, AppState>,
    url: String,
    filename: String,
    expected_sha256: String,
    expected_size: u64,
) -> Result<serde_json::Value, String> {
    let (api_url, launcher_data, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (
            guard.api_base_url.clone(),
            guard.launcher_data_dir.clone(),
            guard.dev_mode,
        )
    };

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    // Pobierz plik
    let data = client
        .download_file(&url)
        .await
        .map_err(|e| format!("Pobieranie nie powiodło się: {e}"))?;

    // Zweryfikuj hash i rozmiar
    let result = launcher_core::artifact_verify::verify_artifact_strict(
        &data,
        &filename,
        &expected_sha256,
        Some(expected_size),
    )
    .map_err(|e| format!("Weryfikacja nie powiodła się: {e}"))?;

    // Zapisz zweryfikowany plik
    let downloads_dir = launcher_data.join("downloads");
    std::fs::create_dir_all(&downloads_dir)
        .map_err(|e| format!("Nie można utworzyć katalogu downloads: {e}"))?;

    let save_path = downloads_dir.join(&filename);
    std::fs::write(&save_path, &data).map_err(|e| format!("Nie można zapisać pliku: {e}"))?;

    Ok(serde_json::json!({
        "savedTo": save_path.display().to_string(),
        "sha256Ok": result.sha256_ok,
        "sizeOk": result.size_ok,
        "actualSize": result.actual_size,
    }))
}

// ─────────────────────────────────────────────
// LR-048: check_launcher_update
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn check_launcher_update(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let (api_url, current_version, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (
            guard.api_base_url.clone(),
            guard.launcher_version.clone(),
            guard.dev_mode,
        )
    };

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let version_resp = client
        .check_launcher_version()
        .await
        .map_err(|e| format!("Nie można sprawdzić wersji: {e}"))?;

    let check_result =
        launcher_core::self_update::check_launcher_version(&current_version, &version_resp);

    match check_result {
        launcher_core::self_update::VersionCheckResult::UpToDate => Ok(serde_json::json!({
            "updateAvailable": false,
            "updateRequired": false,
            "currentVersion": current_version,
            "latestVersion": version_resp.version,
        })),
        launcher_core::self_update::VersionCheckResult::UpdateAvailable {
            current,
            latest,
            url,
            sha256,
            notes,
        } => Ok(serde_json::json!({
            "updateAvailable": true,
            "updateRequired": false,
            "currentVersion": current,
            "latestVersion": latest,
            "url": url,
            "sha256": sha256,
            "notes": notes,
        })),
        launcher_core::self_update::VersionCheckResult::UpdateRequired {
            current,
            latest,
            min_version,
            url,
            sha256,
            notes,
        } => Ok(serde_json::json!({
            "updateAvailable": true,
            "updateRequired": true,
            "currentVersion": current,
            "latestVersion": latest,
            "minVersion": min_version,
            "url": url,
            "sha256": sha256,
            "notes": notes,
        })),
    }
}

// ─────────────────────────────────────────────
// LR-049..050: perform_self_update
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn perform_self_update(
    state: State<'_, AppState>,
    app_handle: tauri::AppHandle,
) -> Result<serde_json::Value, String> {
    let (api_url, current_version, launcher_data, dev_mode) = {
        let guard = state.inner.lock().map_err(|e| e.to_string())?;
        (
            guard.api_base_url.clone(),
            guard.launcher_version.clone(),
            guard.launcher_data_dir.clone(),
            guard.dev_mode,
        )
    };

    // 1. Sprawdź wersję
    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let version_resp = client
        .check_launcher_version()
        .await
        .map_err(|e| format!("Nie można sprawdzić wersji: {e}"))?;

    let check_result =
        launcher_core::self_update::check_launcher_version(&current_version, &version_resp);

    let (url, sha256) = match check_result {
        launcher_core::self_update::VersionCheckResult::UpdateAvailable { url, sha256, .. }
        | launcher_core::self_update::VersionCheckResult::UpdateRequired { url, sha256, .. } => {
            let sha = sha256.ok_or_else(|| {
                "Serwer nie zwrócił SHA-256 paczki — self-update zablokowany (brak weryfikacji)"
                    .to_string()
            })?;
            (url, sha)
        }
        launcher_core::self_update::VersionCheckResult::UpToDate => {
            return Ok(serde_json::json!({
                "status": "up_to_date",
                "message": "Launcher jest aktualny",
            }));
        }
    };

    // 2. Pobierz nową paczkę
    let data = client
        .download_file(&url)
        .await
        .map_err(|e| format!("Pobieranie paczki nie powiodło się: {e}"))?;

    // 3. Weryfikuj SHA-256
    launcher_core::self_update::verify_self_update_package(&data, &sha256)
        .map_err(|e| format!("Weryfikacja paczki: {e}"))?;

    // 4. Stage do staging/
    let exe_path =
        std::env::current_exe().map_err(|e| format!("Nie można ustalić ścieżki exe: {e}"))?;
    let plan = launcher_core::self_update::build_self_update_plan(
        &url,
        &sha256,
        &launcher_data,
        &exe_path,
    );

    launcher_core::self_update::stage_self_update_package(&data, &plan.staging_path)
        .map_err(|e| format!("Staging paczki: {e}"))?;

    // 5. Uruchom helper
    let helper_pid = launcher_core::self_update::launch_helper(&plan)
        .map_err(|e| format!("Uruchomienie helpera: {e}"))?;

    // 6. Zamknij launcher — helper podmieni binarkę i zrestartuje
    // Dajemy chwilę na odesłanie odpowiedzi do frontendu, potem exit.
    let handle = app_handle.clone();
    tokio::spawn(async move {
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
        handle.exit(0);
    });

    Ok(serde_json::json!({
        "status": "restarting",
        "message": "Helper uruchomiony — launcher zostanie zaktualizowany po restarcie",
        "helperPid": helper_pid,
    }))
}

// ─────────────────────────────────────────────
// get_server_status — status serwerów gry
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_server_status(state: State<'_, AppState>) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (g.api_base_url.clone(), g.dev_mode)
    };

    let config = ApiClientConfig {
        base_url: api_url,
        timeout_seconds: 5,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let status = client
        .fetch_server_status()
        .await
        .map_err(|e| format!("Nie można pobrać statusu serwerów: {e}"))?;

    serde_json::to_value(&status).map_err(|e| e.to_string())
}

fn endpoint_status_ok(status: u16, allow_auth_errors: bool) -> bool {
    if (200..300).contains(&status) {
        return true;
    }

    if allow_auth_errors {
        return matches!(status, 400 | 401 | 403 | 405 | 422);
    }

    false
}

#[tauri::command]
pub async fn health_check_critical_endpoints(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let (api_url, channel, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (g.api_base_url.clone(), g.channel.clone(), g.dev_mode)
    };

    let config = ApiClientConfig {
        base_url: api_url,
        timeout_seconds: 8,
        max_retries: 1,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    let mut checks = Vec::new();

    match client.check_launcher_version().await {
        Ok(_) => checks.push(serde_json::json!({
            "endpoint": "launcher-version.php",
            "ok": true,
            "status": 200,
            "detail": "version payload parsed"
        })),
        Err(e) => checks.push(serde_json::json!({
            "endpoint": "launcher-version.php",
            "ok": false,
            "status": serde_json::Value::Null,
            "detail": e.to_string()
        })),
    }

    match client.fetch_manifest_with_signature(&channel).await {
        Ok(_) => checks.push(serde_json::json!({
            "endpoint": format!("update.php?channel={}", channel),
            "ok": true,
            "status": 200,
            "detail": "manifest payload parsed"
        })),
        Err(e) => checks.push(serde_json::json!({
            "endpoint": format!("update.php?channel={}", channel),
            "ok": false,
            "status": serde_json::Value::Null,
            "detail": e.to_string()
        })),
    }

    let login_status = client
        .probe_endpoint_status("login.php")
        .await
        .map_err(|e| e.to_string());
    match login_status {
        Ok(status) => checks.push(serde_json::json!({
            "endpoint": "login.php",
            "ok": endpoint_status_ok(status, true),
            "status": status,
            "detail": if endpoint_status_ok(status, true) { "reachable" } else { "unexpected http status" }
        })),
        Err(e) => checks.push(serde_json::json!({
            "endpoint": "login.php",
            "ok": false,
            "status": serde_json::Value::Null,
            "detail": e
        })),
    }

    let account_context_status = client
        .probe_endpoint_status("account-context.php")
        .await
        .map_err(|e| e.to_string());
    match account_context_status {
        Ok(status) => checks.push(serde_json::json!({
            "endpoint": "account-context.php",
            "ok": endpoint_status_ok(status, true),
            "status": status,
            "detail": if endpoint_status_ok(status, true) { "reachable" } else { "unexpected http status" }
        })),
        Err(e) => checks.push(serde_json::json!({
            "endpoint": "account-context.php",
            "ok": false,
            "status": serde_json::Value::Null,
            "detail": e
        })),
    }

    let overall_ok = checks
        .iter()
        .all(|item| item.get("ok").and_then(|v| v.as_bool()).unwrap_or(false));

    Ok(serde_json::json!({
        "ok": overall_ok,
        "channel": channel,
        "checks": checks
    }))
}

// ─────────────────────────────────────────────
// Faza 8: report_error — raportowanie błędów
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn report_error(
    state: State<'_, AppState>,
    error_code: String,
    message: String,
    context: Option<serde_json::Value>,
) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode, version) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_version.clone(),
        )
    };

    let report = ErrorReportRequest {
        error_code,
        message,
        launcher_version: version,
        os: std::env::consts::OS.to_string(),
        context,
    };

    let config = ApiClientConfig {
        base_url: api_url,
        timeout_seconds: 5,
        max_retries: 1,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    match client.report_error(&report).await {
        Ok(resp) => serde_json::to_value(&resp).map_err(|e| e.to_string()),
        Err(e) => {
            tracing::warn!("Nie udało się wysłać raportu: {}", e);
            Ok(serde_json::json!({"status": "failed_silently", "reason": e.to_string()}))
        }
    }
}

// ─────────────────────────────────────────────
// Uninstall: remove game files
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn uninstall_game_files(
    state: State<'_, AppState>,
) -> Result<String, String> {
    let client_dir = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        g.client_dir.clone()
    };

    if !client_dir.exists() {
        return Ok("No game files to remove.".to_string());
    }

    std::fs::remove_dir_all(&client_dir)
        .map_err(|e| format!("Failed to remove game files: {e}"))?;

    tracing::info!("Game files removed: {}", client_dir.display());
    Ok("Game files removed.".to_string())
}

// ─────────────────────────────────────────────
// Uninstall: launch bootstrap --uninstall
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn uninstall_launcher() -> Result<String, String> {
    let exe_dir = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|d| d.to_path_buf()))
        .ok_or("Cannot determine launcher directory")?;

    let bootstrap_name = if cfg!(target_os = "windows") {
        "launcher-bootstrap.exe"
    } else {
        "launcher-bootstrap"
    };

    let bootstrap_path = exe_dir.join(bootstrap_name);
    if !bootstrap_path.exists() {
        return Err(format!(
            "Uninstaller not found: {}",
            bootstrap_path.display()
        ));
    }

    std::process::Command::new(&bootstrap_path)
        .arg("--uninstall")
        .spawn()
        .map_err(|e| format!("Failed to start uninstaller: {e}"))?;

    tracing::info!("Uninstaller started: {}", bootstrap_path.display());

    // Give the uninstaller a moment to start, then exit
    std::thread::sleep(std::time::Duration::from_millis(500));
    std::process::exit(0);
}
