//! LR-032: Tauri command handlers — thin wrappers wokół launcher-core.
//!
//! Każda komenda:
//! 1. Pobiera stan z `AppState`.
//! 2. Deleguje do launcher-core / launcher-api.
//! 3. Zwraca DTO (nigdy surowe struktury).

use tauri::State;

use common_models::api_responses::LaunchTokenRequest;
use common_models::dto::*;
use common_models::installed_state::InstalledState;

use launcher_api::client::{ApiClient, ApiClientConfig};
use launcher_core::file_index::LocalFileIndex;
use launcher_core::integrity::compute_files_hash;
use launcher_core::patcher::{self, PatchContext};
use launcher_core::planner::build_update_plan;
use launcher_core::process_runner::{launch_client, LaunchConfig};
use launcher_core::repair::diagnose_installation;
use launcher_core::serverlist_sync;
use launcher_core::state as core_state;

use crate::state::AppState;

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
                    version,
                ))
            } else {
                Ok(LauncherStatusDto::checking(
                    guard.launcher_version.clone(),
                    guard.channel.clone(),
                ))
            }
        }
        None => Ok(LauncherStatusDto::checking(
            guard.launcher_version.clone(),
            guard.channel.clone(),
        )),
    }
}

// ─────────────────────────────────────────────
// LR-033+034: check_for_updates — sprawdź manifest
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn check_for_updates(state: State<'_, AppState>) -> Result<UpdatePlanSummaryDto, String> {
    let (api_url, channel, client_dir, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.dev_mode,
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    // Pobierz manifest
    let manifest = api
        .fetch_manifest(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

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

    // --- Faza 1: Manifest ---
    let manifest = api
        .fetch_manifest(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

    // --- Faza 2: Skan ---
    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir)
        .map_err(|e| format!("Błąd skanowania: {e}"))?;

    let plan = build_update_plan(&manifest, &index).map_err(|e| format!("Błąd planowania: {e}"))?;

    if plan.is_up_to_date {
        let now = chrono_utc_now();
        installed.mark_success(
            manifest.version.clone(),
            manifest.manifest_id.clone(),
            installed.current_files_hash.clone().unwrap_or_default(),
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
// LR-035: launch_game — start klienta
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn launch_game(state: State<'_, AppState>) -> Result<String, String> {
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

    let config = LaunchConfig {
        client_exe_path: client_exe.display().to_string(),
        working_dir: client_dir.display().to_string(),
        launch_token: token_resp.token,
        channel: channel.clone(),
        extra_env: vec![],
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
    let (api_url, channel, client_dir, dev_mode) = {
        let g = state.inner.lock().map_err(|e| e.to_string())?;
        (
            g.api_base_url.clone(),
            g.channel.clone(),
            g.client_dir.clone(),
            g.dev_mode,
        )
    };

    let api = ApiClient::new(ApiClientConfig {
        base_url: api_url,
        dev_mode,
        ..Default::default()
    })
    .map_err(|e| e.to_string())?;

    let manifest = api
        .fetch_manifest(&channel)
        .await
        .map_err(|e| format!("LCH_MANIFEST_FETCH_FAILED: {e}"))?;

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
pub async fn change_channel(channel: String, state: State<'_, AppState>) -> Result<String, String> {
    let valid = ["stable", "test", "dev"];
    if !valid.contains(&channel.as_str()) {
        return Err(format!(
            "Nieprawidłowy kanał: {channel}. Dostępne: stable, test, dev"
        ));
    }

    let mut g = state.inner.lock().map_err(|e| e.to_string())?;
    g.channel = channel.clone();

    tracing::info!("Zmieniono kanał na: {channel}");
    Ok(format!("Kanał zmieniony na: {channel}"))
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
    content.push_str("=== SerwerCanary Launcher — eksport logów ===\n\n");

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
        (guard.api_base_url.clone(), guard.channel.clone(), guard.dev_mode)
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
        (guard.api_base_url.clone(), guard.launcher_data_dir.clone(), guard.dev_mode)
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
        (guard.api_base_url.clone(), guard.launcher_version.clone(), guard.dev_mode)
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
pub async fn perform_self_update(state: State<'_, AppState>) -> Result<serde_json::Value, String> {
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

    Ok(serde_json::json!({
        "status": "restarting",
        "message": "Helper uruchomiony — launcher zostanie zaktualizowany po restarcie",
        "helperPid": helper_pid,
    }))

    // UWAGA: Po tym wywołaniu launcher powinien się zamknąć!
    // W Tauri: caller (frontend) powinien wywołać window.close() lub process.exit()
}

// ─────────────────────────────────────────────
// get_server_status — status serwerów gry
// ─────────────────────────────────────────────

#[tauri::command]
pub async fn get_server_status(
    state: State<'_, AppState>,
) -> Result<serde_json::Value, String> {
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
