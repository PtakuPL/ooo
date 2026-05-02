//! LR-032: Tauri command handlers — thin wrappers wokół launcher-core.
//!
//! Każda komenda:
//! 1. Pobiera stan z `AppState`.
//! 2. Deleguje do launcher-core / launcher-api.
//! 3. Zwraca DTO (nigdy surowe struktury).

use semver::Version;
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use tauri::State;

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
use launcher_core::state as core_state;

use crate::session_store;
use crate::state::AppState;

// ─────────────────────────────────────────────
// Helper: buduje SignatureConfig z klucza publicznego
// ─────────────────────────────────────────────

fn build_signature_config(
    public_key_hex: &Option<String>,
    require_signature: bool,
) -> SignatureConfig {
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
    std::fs::remove_file(&probe).map_err(|e| {
        format!(
            "LCH_PREFLIGHT_NOT_WRITABLE: {} cleanup failed: {}",
            label, e
        )
    })?;
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
    let quarantined = quarantine_player_runtime_leftovers(client_dir, launcher_data)?;
    if !quarantined.is_empty() {
        tracing::warn!(
            "Player runtime cleanup before launch quarantined {} leftover files: {:?}",
            quarantined.len(),
            quarantined
        );
    }
    Ok(())
}

fn quarantine_player_runtime_leftovers(
    client_dir: &Path,
    launcher_data: &Path,
) -> Result<Vec<String>, String> {
    let mut candidates: Vec<PathBuf> = Vec::new();
    let root_files = [
        "serverlist.lua",
        "serverlist.json",
        "init_serverlist.lua",
        "otclientrc.lua",
        "otclientrc.lua.default",
        "start_dev.bat",
        "start_dev.sh",
        "start_player.bat",
        "start_player.sh",
        "OTClient.sublime-project",
        "README.md",
        "README.txt",
        "AUTHORS",
        "BUGS",
    ];

    for name in root_files {
        let path = client_dir.join(name);
        if path.exists() {
            candidates.push(PathBuf::from(name));
        }
    }

    let root_dirs = [
        "serverSIDE",
        "data/styles.bak",
        "data/locales/disabled",
        "modules/.project",
    ];
    for name in root_dirs {
        let path = client_dir.join(name);
        if path.exists() {
            candidates.push(PathBuf::from(name));
        }
    }

    if candidates.is_empty() {
        return Ok(Vec::new());
    }

    let stamp = chrono_utc_now().replace([':', '-'], "");
    let quarantine_dir = launcher_data
        .join("quarantine")
        .join(format!("player-leftovers-{stamp}"));
    fs::create_dir_all(&quarantine_dir)
        .map_err(|e| format!("LCH_PLAYER_CLEANUP_QUARANTINE_CREATE_FAILED: {e}"))?;

    let mut moved = Vec::new();
    for rel in candidates {
        let src = client_dir.join(&rel);
        if !src.exists() {
            continue;
        }
        let dst = quarantine_dir.join(&rel);
        if let Some(parent) = dst.parent() {
            fs::create_dir_all(parent).map_err(|e| {
                format!(
                    "LCH_PLAYER_CLEANUP_QUARANTINE_PARENT_FAILED: {}: {e}",
                    rel.display()
                )
            })?;
        }
        fs::rename(&src, &dst).map_err(|e| {
            format!(
                "LCH_PLAYER_CLEANUP_QUARANTINE_MOVE_FAILED: {}: {e}",
                rel.display()
            )
        })?;
        moved.push(rel.to_string_lossy().to_string());
    }

    Ok(moved)
}

fn load_stored_launcher_session_key(launcher_data: &Path) -> Result<String, String> {
    session_store::load_session_key(launcher_data)?
        .ok_or_else(|| "Brak sessionKey launchera.".to_string())
}

fn store_launcher_session_key(launcher_data: &Path, session_key: &str) -> Result<String, String> {
    session_store::store_session_key(launcher_data, session_key)
}

fn clear_stored_launcher_session_key(launcher_data: &Path) -> Result<(), String> {
    session_store::clear_session_key(launcher_data)
}

fn should_clear_stored_session(error: &str) -> bool {
    let lower = error.to_ascii_lowercase();
    [
        "invalid_session",
        "expired_session",
        "missing sessionkey",
        "missing_session_key",
        "invalid or expired session",
        "session expired",
    ]
    .iter()
    .any(|needle| lower.contains(needle))
}

fn normalize_profile_mode(mode: &str) -> Result<&'static str, String> {
    match mode.trim().to_ascii_lowercase().as_str() {
        "all" => Ok("all"),
        "classic74" => Ok("classic74"),
        "modern" => Ok("modern"),
        _ => Err("Nieprawidlowy tryb profilu. Dozwolone: all, classic74, modern".to_string()),
    }
}

fn normalize_launch_mode(mode: Option<&str>) -> Result<Option<&'static str>, String> {
    let Some(raw_mode) = mode else {
        return Ok(None);
    };
    match normalize_profile_mode(raw_mode)? {
        "classic74" => Ok(Some("classic74")),
        "modern" => Ok(Some("modern")),
        _ => Err("Tryb launchera musi byc konkretny: classic74 albo modern.".to_string()),
    }
}

fn build_launcher_account_context_response(ctx: &serde_json::Value) -> serde_json::Value {
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

    serde_json::json!({
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
    })
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

    if bootstrap_mode
        && manifest
            .files_hash_expected
            .as_deref()
            .unwrap_or("")
            .trim()
            .is_empty()
    {
        return Err("LCH_BOOTSTRAP_FILES_HASH_EXPECTED_MISSING".to_string());
    }

    enforce_manifest_launcher_compat(manifest.min_launcher_version.as_deref(), &launcher_version)?;

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

    if bootstrap_mode
        && manifest
            .files_hash_expected
            .as_deref()
            .unwrap_or("")
            .trim()
            .is_empty()
    {
        return Err("LCH_BOOTSTRAP_FILES_HASH_EXPECTED_MISSING".to_string());
    }

    enforce_manifest_launcher_compat(manifest.min_launcher_version.as_deref(), &launcher_version)?;

    // --- Faza 2: Skan ---
    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir)
        .map_err(|e| format!("Błąd skanowania: {e}"))?;

    let plan = build_update_plan(&manifest, &index).map_err(|e| format!("Błąd planowania: {e}"))?;

    run_preflight_for_update(&client_dir, &launcher_data, plan.total_download_bytes)?;

    if plan.is_up_to_date {
        let quarantined = quarantine_player_runtime_leftovers(&client_dir, &launcher_data)?;
        if !quarantined.is_empty() {
            tracing::warn!(
                "Player runtime cleanup on up-to-date install quarantined {} leftover files: {:?}",
                quarantined.len(),
                quarantined
            );
        }

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

    let quarantined = quarantine_player_runtime_leftovers(&client_dir, &launcher_data)?;
    if !quarantined.is_empty() {
        tracing::warn!(
            "Player runtime cleanup after update quarantined {} leftover files: {:?}",
            quarantined.len(),
            quarantined
        );
    }

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

    if !manifest.servers.is_empty() {
        tracing::info!(
            "Skipping launcher-generated serverlist files for player runtime; sealed client config/API ticket are authoritative"
        );
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

    enforce_manifest_launcher_compat(manifest.min_launcher_version.as_deref(), &launcher_version)?;

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

    enforce_manifest_launcher_compat(manifest.min_launcher_version.as_deref(), &launcher_version)?;

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

    let report =
        launcher_core::integrity::verify_critical_files(&manifest.critical_files, &client_dir);
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
    character_hint: Option<String>,
    game_mode: Option<String>,
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

    let installed = core_state::load_state(&state_path).map_err(|_| {
        "LCH_NO_CLIENT_FILES: Brak stanu instalacji. Uruchom najpierw aktualizację.".to_string()
    })?;

    let files_hash = installed
        .current_files_hash
        .as_deref()
        .ok_or("LCH_NO_FILES_HASH: Brak filesHash. Uruchom aktualizację.")?
        .to_string();

    let manifest_version = installed
        .current_manifest_version
        .as_deref()
        .unwrap_or("unknown")
        .to_string();
    let session_token = load_stored_launcher_session_key(&launcher_data)?;
    let requested_launch_mode = normalize_launch_mode(game_mode.as_deref())?;

    // Pobierz token
    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    if let Some(mode) = requested_launch_mode {
        api.switch_account_profile(&session_token, mode)
            .await
            .map_err(|e| format!("ACCOUNT_PROFILE_SWITCH_FAILED: {e}"))?;
    }

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
    extra_env.push(("OTC_SESSION_TOKEN".into(), session_token));

    if let Some(ref hint) = character_hint {
        let trimmed = hint.trim();
        if !trimmed.is_empty() && trimmed.len() <= 64 {
            extra_env.push(("OTC_CHARACTER_HINT".into(), trimmed.to_string()));
        }
    }

    if let Some(mode) = requested_launch_mode {
        extra_env.push(("OTC_GAME_MODE".into(), mode.to_string()));
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

/// Extract the scheme+host(+port) origin from a full base URL.
/// Returns `None` if `base_url` does not start with `http://` or `https://`.
///
/// Used by `download_and_verify_artifact` to resolve relative artifact URLs
/// returned from `installer-catalog.php` (e.g. `/files/foo.zip`).
fn extract_origin(base_url: &str) -> Option<String> {
    let (scheme, rest) = if let Some(r) = base_url.strip_prefix("https://") {
        ("https://", r)
    } else if let Some(r) = base_url.strip_prefix("http://") {
        ("http://", r)
    } else {
        return None;
    };
    let host_end = rest.find('/').unwrap_or(rest.len());
    Some(format!("{scheme}{}", &rest[..host_end]))
}

/// Resolve an artifact URL from `installer-catalog.php` to an absolute URL.
/// Relative paths (`/files/...`) and protocol-relative (`//host/...`) are
/// resolved against `api_base_url`'s origin. Absolute http(s) URLs pass through.
fn resolve_artifact_url(api_base_url: &str, url: &str) -> Result<String, String> {
    let trimmed = url.trim();
    if trimmed.is_empty() {
        return Err("Pusty URL artefaktu w katalogu".to_string());
    }
    if trimmed.starts_with("https://") || trimmed.starts_with("http://") {
        return Ok(trimmed.to_string());
    }
    let origin = extract_origin(api_base_url)
        .ok_or_else(|| format!("Nieprawidłowy api_base_url: {api_base_url}"))?;
    if let Some(rest) = trimmed.strip_prefix("//") {
        let scheme = if origin.starts_with("https://") {
            "https:"
        } else {
            "http:"
        };
        return Ok(format!("{scheme}//{rest}"));
    }
    if trimmed.starts_with('/') {
        return Ok(format!("{origin}{trimmed}"));
    }
    Ok(format!("{}/{trimmed}", api_base_url.trim_end_matches('/')))
}

/// Returns true iff `s` is a 64-character hex string (lower or upper case).
fn is_valid_sha256_hex(s: &str) -> bool {
    let t = s.trim();
    t.len() == 64
        && t.chars()
            .all(|c| matches!(c, '0'..='9' | 'a'..='f' | 'A'..='F'))
}

fn pending_account_sync_path(launcher_data: &Path) -> std::path::PathBuf {
    launcher_data.join("pending_account_sync_token.txt")
}

fn read_pending_account_sync_token(launcher_data: &Path) -> Option<(String, Option<String>)> {
    let path = pending_account_sync_path(launcher_data);
    let content = std::fs::read_to_string(path).ok()?;
    let mut lines = content.lines();
    let token = lines.next()?.trim().to_string();
    if token.len() != 64 || !token.chars().all(|c| c.is_ascii_hexdigit()) {
        return None;
    }
    let verifier = lines
        .next()
        .map(|v| v.trim().to_string())
        .filter(|v| v.len() == 64 && v.chars().all(|c| c.is_ascii_hexdigit()));
    Some((
        token.to_ascii_lowercase(),
        verifier.map(|v| v.to_ascii_lowercase()),
    ))
}

fn clear_pending_account_sync_token(launcher_data: &Path) {
    let path = pending_account_sync_path(launcher_data);
    let _ = std::fs::remove_file(path);
}

fn normalize_website_redirect_path(redirect_path: &str) -> Result<String, String> {
    let trimmed = redirect_path.trim();
    if trimmed.is_empty() {
        return Err("Brak redirect path.".to_string());
    }
    if !trimmed.starts_with('/') || trimmed.starts_with("//") {
        return Err("Redirect musi zaczynac sie od pojedynczego '/'.".to_string());
    }
    Ok(trimmed.to_string())
}

fn should_clear_account_sync_error(error: &str) -> bool {
    [
        "invalid_sync_token",
        "sync_token_already_used",
        "sync_token_expired",
        "target_mismatch",
        "source_mismatch",
    ]
    .iter()
    .any(|needle| error.contains(needle))
}

async fn build_www_sync_url_payload(
    api_url: String,
    dev_mode: bool,
    launcher_data: PathBuf,
    redirect_path: &str,
) -> Result<serde_json::Value, String> {
    let safe_redirect = normalize_website_redirect_path(redirect_path)?;
    let stored_session_key = load_stored_launcher_session_key(&launcher_data)?;

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let sync = api
        .request_account_sync_token(&stored_session_key, "launcher", "www")
        .await
        .map_err(|e| format!("SYNC_TOKEN_REQUEST_FAILED: {e}"))?;

    let consume_url = sync
        .consume_url
        .clone()
        .ok_or_else(|| "SYNC_TOKEN_CONSUME_URL_MISSING".to_string())?;

    let verifier = sync
        .verifier
        .clone()
        .ok_or_else(|| "SYNC_TOKEN_VERIFIER_MISSING".to_string())?;

    // SEC-P2-001: token + verifier ida w hash, a redirect w query string.
    let base_url = append_query_param(&consume_url, "redirect", &safe_redirect);
    let final_url = format!(
        "{}#t={}&v={}",
        base_url,
        percent_encode_component(&sync.sync_token),
        percent_encode_component(&verifier),
    );

    Ok(serde_json::json!({
        "ok": true,
        "url": final_url,
        "redirect": safe_redirect,
        "syncToken": sync.sync_token,
        "expiresAt": sync.expires_at,
        "consumeUrl": consume_url
    }))
}

#[tauri::command]
pub async fn build_create_character_url(
    state: State<'_, AppState>,
    mode: String,
) -> Result<serde_json::Value, String> {
    let safe_mode = match mode.trim().to_ascii_lowercase().as_str() {
        "classic74" => "classic74",
        "modern" => "modern",
        _ => return Err("Nieprawidłowy tryb. Dozwolone: classic74, modern".to_string()),
    };

    let (api_url, dev_mode, launcher_data) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_data_dir.clone(),
        )
    };
    let redirect = format!("/account/createcharacter?source=launcher&mode={safe_mode}");
    let mut payload =
        build_www_sync_url_payload(api_url, dev_mode, launcher_data, &redirect).await?;
    if let Some(obj) = payload.as_object_mut() {
        obj.insert(
            "mode".to_string(),
            serde_json::Value::String(safe_mode.to_string()),
        );
    }
    Ok(payload)
}

#[tauri::command]
pub async fn build_website_sync_url(
    state: State<'_, AppState>,
    redirect_path: String,
) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode, launcher_data) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_data_dir.clone(),
        )
    };
    build_www_sync_url_payload(api_url, dev_mode, launcher_data, &redirect_path).await
}

#[tauri::command]
pub async fn consume_pending_account_sync(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode, launcher_data, memory_token, memory_verifier) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_data_dir.clone(),
            g.pending_account_sync_token.clone(),
            g.pending_account_sync_verifier.clone(),
        )
    };

    let file_sync = read_pending_account_sync_token(&launcher_data);
    let (sync_token, verifier) = match file_sync {
        Some((t, v)) => (Some(t), v),
        None => (memory_token, memory_verifier),
    };
    let Some(sync_token) = sync_token else {
        return Ok(serde_json::json!({
            "ok": false,
            "pending": false
        }));
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    tracing::info!(
        "Launcher consume pending WWW sync token start: api_url={}",
        api.config.base_url
    );

    match api
        .consume_account_sync_token(&sync_token, "www", "launcher", verifier.as_deref())
        .await
    {
        Ok(resp) => {
            store_launcher_session_key(&launcher_data, &resp.session.session_key)?;
            {
                let mut g = state.inner.lock().map_err(|e| e.to_string())?;
                g.pending_account_sync_token = None;
                g.pending_account_sync_verifier = None;
            }
            clear_pending_account_sync_token(&launcher_data);

            Ok(serde_json::json!({
                "ok": true,
                "pending": true,
                "sessionStored": true,
                "gameMode": resp.session.game_mode,
                "sessionExpiresAt": resp.session.expires_at,
                "accountId": resp.account.id,
                "accountName": resp.account.name,
                "email": resp.account.email,
                "counts": resp.counts
            }))
        }
        Err(e) => {
            let err = format!("ACCOUNT_SYNC_CONSUME_FAILED: {e}");
            tracing::warn!(
                "Launcher consume pending WWW sync token failed: api_url={}, error={}",
                api.config.base_url,
                err
            );

            if should_clear_account_sync_error(&err) {
                let mut g = state.inner.lock().map_err(|e| e.to_string())?;
                g.pending_account_sync_token = None;
                g.pending_account_sync_verifier = None;
                clear_pending_account_sync_token(&launcher_data);
            }

            Err(err)
        }
    }
}

#[tauri::command]
pub async fn refresh_launcher_account_context(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let (api_url, dev_mode, launcher_data) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_data_dir.clone(),
        )
    };
    let stored_session_key = load_stored_launcher_session_key(&launcher_data)?;

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let ctx = api
        .fetch_account_context(&stored_session_key)
        .await
        .map_err(|e| {
            let err = format!("ACCOUNT_CONTEXT_REFRESH_FAILED: {e}");
            if should_clear_stored_session(&err) {
                let _ = clear_stored_launcher_session_key(&launcher_data);
            }
            err
        })?;

    Ok(build_launcher_account_context_response(&ctx))
}

#[tauri::command]
pub async fn switch_launcher_account_profile(
    state: State<'_, AppState>,
    game_mode: String,
) -> Result<serde_json::Value, String> {
    let safe_mode = normalize_profile_mode(&game_mode)?;

    let (api_url, dev_mode, launcher_data) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.dev_mode,
            g.launcher_data_dir.clone(),
        )
    };
    let stored_session_key = load_stored_launcher_session_key(&launcher_data)?;

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    api.switch_account_profile(&stored_session_key, safe_mode)
        .await
        .map_err(|e| {
            let err = format!("ACCOUNT_PROFILE_SWITCH_FAILED: {e}");
            if should_clear_stored_session(&err) {
                let _ = clear_stored_launcher_session_key(&launcher_data);
            }
            err
        })?;

    let ctx = api
        .fetch_account_context(&stored_session_key)
        .await
        .map_err(|e| format!("ACCOUNT_CONTEXT_REFRESH_FAILED: {e}"))?;

    Ok(build_launcher_account_context_response(&ctx))
}

// ─────────────────────────────────────────────
// LK-012: Fetch game profiles (public, no auth)
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn fetch_launcher_game_profiles(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
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

    let profiles = api
        .fetch_game_profiles()
        .await
        .map_err(|e| format!("GAME_PROFILES_FETCH_FAILED: {e}"))?;

    Ok(profiles)
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

    // B3: Fresh install — logowanie bez launchToken gdy brak installed_state.json
    let installed = load_installed_state_or_none(&launcher_data);
    let fresh_install = is_bootstrap_install(installed.as_ref());

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    tracing::info!(
        "Launcher account login start: api_url={}, dev_mode={}, fresh_install={}",
        api.config.base_url,
        dev_mode,
        fresh_install
    );

    let launch_token_str = if !fresh_install {
        let files_hash = installed
            .as_ref()
            .and_then(|s| s.current_files_hash.as_deref())
            .unwrap_or_default()
            .to_string();
        let manifest_version = installed
            .as_ref()
            .and_then(|s| s.current_manifest_version.as_deref())
            .unwrap_or("unknown")
            .to_string();
        match api
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
            Ok(token) => Some(token.token),
            Err(e) => {
                tracing::warn!(
                    "Nie udalo sie pobrac launchToken (api_url={}, fresh_install={}): {}",
                    api.config.base_url,
                    fresh_install,
                    e
                );
                None
            }
        }
    } else {
        tracing::info!("Fresh install — logowanie bez launchToken");
        None
    };

    let login_resp = match api
        .login_account(
            &canonical_email,
            &password,
            "all",
            launch_token_str.as_deref(),
            fresh_install,
        )
        .await
    {
        Ok(resp) => resp,
        Err(e) => {
            let err_str = format!("{e}");
            tracing::warn!(
                "Launcher account login failed before session parse: api_url={}, fresh_install={}, has_launch_token={}, error={}",
                api.config.base_url,
                fresh_install,
                !launch_token_str.as_deref().unwrap_or("").is_empty(),
                err_str
            );
            // If login failed due to token issues (CLIENT_LOCKED enforcement) and
            // we weren't already in fresh_install mode, retry as fresh install.
            // This handles stale installed_state.json after bootstrap update.
            if !fresh_install && err_str.contains("LCH_TOKEN") {
                tracing::warn!(
                    "Login rejected by LCH_TOKEN check with stale token — retrying as fresh install"
                );
                api.login_account(&canonical_email, &password, "all", None, true)
                    .await
                    .map_err(|e2| format!("ACCOUNT_LOGIN_FAILED: {e2}"))?
            } else {
                return Err(format!("ACCOUNT_LOGIN_FAILED: {e}"));
            }
        }
    };

    let session_key = login_resp
        .get("session")
        .and_then(|s| s.get("sessionkey"))
        .and_then(|v| v.as_str())
        .unwrap_or("")
        .trim()
        .to_string();
    if session_key.is_empty() {
        tracing::warn!(
            "Launcher account login returned success without sessionkey: api_url={}, fresh_install={}",
            api.config.base_url,
            fresh_install
        );
        return Err("ACCOUNT_LOGIN_FAILED: Brak sessionkey w odpowiedzi login.php".to_string());
    }
    store_launcher_session_key(&launcher_data, &session_key)?;

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
        "sessionStored": true,
        "gameMode": game_mode,
        "email": canonical_email,
        "worldCount": world_count,
        "characterCount": character_count,
        "freshInstall": fresh_install
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

    // B3: Fresh install — rejestracja nie wymaga installed_state.json
    let installed = load_installed_state_or_none(&launcher_data);
    let fresh_install = is_bootstrap_install(installed.as_ref());

    let files_hash = installed
        .as_ref()
        .and_then(|s| s.current_files_hash.as_deref())
        .unwrap_or_default()
        .to_string();
    let manifest_version = installed
        .as_ref()
        .and_then(|s| s.current_manifest_version.as_deref())
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

    let launch_token = if fresh_install {
        tracing::info!("Fresh install — auto-login bez launchToken");
        None
    } else {
        match api
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
            Ok(token) => Some(token),
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
        }
    };

    let login_result = api
        .login_account(
            &returned_email,
            &password,
            "all",
            launch_token.as_ref().map(|t| t.token.as_str()),
            fresh_install,
        )
        .await;

    // CLIENT_LOCKED fallback: retry as fresh install if token was stale
    let login_resp = match login_result {
        Ok(resp) => Ok(resp),
        Err(ref e) if !fresh_install && format!("{e}").contains("LCH_TOKEN") => {
            tracing::warn!(
                "Auto-login after register rejected by LCH_TOKEN check — retrying as fresh install"
            );
            api.login_account(&returned_email, &password, "all", None, true)
                .await
        }
        Err(e) => Err(e),
    };

    match login_resp {
        Ok(login_resp) => {
            let session_key = login_resp
                .get("session")
                .and_then(|s| s.get("sessionkey"))
                .and_then(|v| v.as_str())
                .unwrap_or("")
                .trim()
                .to_string();
            let auto_login = !session_key.is_empty();
            if auto_login {
                store_launcher_session_key(&launcher_data, &session_key)?;
            }

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
                "autoLogin": auto_login,
                "sessionStored": auto_login,
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

#[tauri::command]
pub async fn clear_launcher_session(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
    let launcher_data = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        g.launcher_data_dir.clone()
    };
    clear_stored_launcher_session_key(&launcher_data)?;
    Ok(serde_json::json!({
        "ok": true
    }))
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
// LR-045: Client Pack Catalog
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_client_pack_catalog(
    state: State<'_, AppState>,
    profile: Option<String>,
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

    let profile_str = profile.as_deref().unwrap_or("player");
    let catalog = client
        .fetch_client_pack_catalog(&channel, profile_str)
        .await
        .map_err(|e| format!("Błąd pobierania katalogu klienta: {e}"))?;

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

    // Reject early: relative URLs from the catalog must be resolvable, and the
    // catalog must publish a valid SHA-256. Without these we cannot anchor the
    // trust chain even if `verify_artifact_strict` would later catch a mismatch.
    if !is_valid_sha256_hex(&expected_sha256) {
        return Err(format!(
            "Brak/nieprawidłowy SHA-256 dla '{filename}' (oczekiwane 64 znaki hex)"
        ));
    }
    let resolved_url = resolve_artifact_url(&api_url, &url)?;

    let config = launcher_api::client::ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    };
    let client = ApiClient::new(config).map_err(|e| e.to_string())?;

    // Pobierz plik
    let data = client
        .download_file(&resolved_url)
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
pub async fn uninstall_game_files(state: State<'_, AppState>) -> Result<String, String> {
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

// ─────────────────────────────────────────────
// Bootstrap language preference
// ─────────────────────────────────────────────

/// Read the language preference saved by the bootstrap installer (language.conf).
/// Returns the locale code (e.g. "pl", "en", "de") or empty string if not found.
#[tauri::command]
pub fn get_bootstrap_language() -> String {
    let path = bootstrap_language_conf_path();
    match path {
        Some(p) => std::fs::read_to_string(p)
            .unwrap_or_default()
            .trim()
            .to_string(),
        None => String::new(),
    }
}

fn bootstrap_language_conf_path() -> Option<std::path::PathBuf> {
    #[cfg(target_os = "windows")]
    {
        std::env::var("LOCALAPPDATA").ok().map(|p| {
            std::path::PathBuf::from(p)
                .join("RedDaxe")
                .join("language.conf")
        })
    }
    #[cfg(not(target_os = "windows"))]
    {
        std::env::var("HOME").ok().map(|p| {
            std::path::PathBuf::from(p)
                .join(".config")
                .join("RedDaxe")
                .join("language.conf")
        })
    }
}
