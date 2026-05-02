//! Flow CLI — orkiestracja pełnego cyklu launcher check→update→hash→token→launch.
//!
//! Każdy krok loguje postęp i obsługuje błędy z kodami `LCH_*`.

use std::fs;
use std::path::{Path, PathBuf};

use common_models::api_responses::LaunchTokenRequest;
use common_models::installed_state::{InstalledState, UpdateTxStatus};
use common_models::manifest::NormalizedManifest;

use launcher_api::client::{ApiClient, ApiClientConfig, ApiError};
use launcher_core::file_index::LocalFileIndex;
use launcher_core::integrity::compute_files_hash;
use launcher_core::patcher::{self, PatchContext};
use launcher_core::planner;
use launcher_core::process_runner::{self, LaunchConfig};
use launcher_core::repair;
use launcher_core::state;

use crate::cli::CliArgs;

// ─────────────────────────────────────────────────────────
// Pełny flow: check → update → hash → token → launch
// ─────────────────────────────────────────────────────────

/// Pełny flow: check → update → hash → token → launch.
/// Zwraca kod wyjścia (0 = sukces).
pub async fn run_full_flow(args: &CliArgs) -> i32 {
    if args.base_url.is_empty() {
        eprintln!("[BŁĄD] Wymagany --base-url");
        return 1;
    }

    let client_dir = PathBuf::from(&args.client_dir);
    let launcher_data = resolve_launcher_data(&client_dir, &args.launcher_data_dir);

    // 1. Sprawdź wersję launchera
    tracing::info!("=== Krok 1/5: Sprawdzam wersję launchera ===");
    let api = match create_api_client(args) {
        Ok(c) => c,
        Err(code) => return code,
    };

    match api.check_launcher_version().await {
        Ok(ver) => {
            tracing::info!(
                "Wersja serwera: {}, min: {}, required: {}",
                ver.version,
                ver.min_version,
                ver.required
            );
            if ver.required {
                if let Ok(remote) = semver::Version::parse(&ver.version) {
                    if let Ok(local) = semver::Version::parse(&args.launcher_version) {
                        if remote > local {
                            eprintln!(
                                "[KRYTYCZNY] Wymagana aktualizacja launchera: {} → {}",
                                args.launcher_version, ver.version
                            );
                            eprintln!("Pobierz nową wersję z: {}", ver.url);
                            return 10; // LCH_LAUNCHER_UPDATE_REQUIRED
                        }
                    }
                }
            }
        }
        Err(e) => {
            tracing::warn!("Nie mogę sprawdzić wersji launchera: {}", e);
            // Nie blokujemy — kontynuujemy z update
        }
    }

    // 2. Aktualizacja
    tracing::info!("=== Krok 2/5: Aktualizacja klienta ===");
    let manifest = match run_update_flow(&api, args, &client_dir, &launcher_data).await {
        Ok(m) => m,
        Err(code) => return code,
    };

    // 3. Oblicz filesHash
    tracing::info!("=== Krok 3/5: Obliczam filesHash ===");
    let files_hash = match compute_files_hash(&manifest, &client_dir) {
        Ok(h) => {
            tracing::info!("filesHash: {}", h);
            h
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę obliczyć filesHash: {}", e);
            return 20; // LCH_HASH_COMPUTE_FAILED
        }
    };

    // 4. Pobierz launch-token
    tracing::info!("=== Krok 4/5: Pobieram launch-token ===");
    let token = match request_token(&api, args, &manifest, &files_hash).await {
        Ok(t) => t,
        Err(code) => return code,
    };

    // 5. Uruchom klienta
    tracing::info!("=== Krok 5/5: Uruchamiam klienta ===");
    let exe_path = client_dir.join(&args.client_exe);
    let launch_cfg = LaunchConfig {
        client_exe_path: exe_path.to_string_lossy().to_string(),
        working_dir: client_dir.to_string_lossy().to_string(),
        launch_token: token,
        channel: args.channel.clone(),
        extra_env: Vec::new(),
    };

    match process_runner::launch_client(&launch_cfg) {
        Ok(result) => {
            tracing::info!("Klient uruchomiony, PID: {:?}", result.pid);
            0
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę uruchomić klienta: {}", e);
            50 // LCH_CLIENT_START_FAILED
        }
    }
}

// ─────────────────────────────────────────────────────────
// Tylko update (bez startu klienta)
// ─────────────────────────────────────────────────────────

/// Tylko aktualizacja — bez pobierania tokena i uruchamiania klienta.
pub async fn run_update_only(args: &CliArgs) -> i32 {
    if args.base_url.is_empty() {
        eprintln!("[BŁĄD] Wymagany --base-url");
        return 1;
    }

    let client_dir = PathBuf::from(&args.client_dir);
    let launcher_data = resolve_launcher_data(&client_dir, &args.launcher_data_dir);

    let api = match create_api_client(args) {
        Ok(c) => c,
        Err(code) => return code,
    };

    match run_update_flow(&api, args, &client_dir, &launcher_data).await {
        Ok(manifest) => {
            // Oblicz filesHash po update
            match compute_files_hash(&manifest, &client_dir) {
                Ok(h) => {
                    println!("filesHash: {}", h);
                    0
                }
                Err(e) => {
                    eprintln!("[BŁĄD] Nie mogę obliczyć filesHash po update: {}", e);
                    20
                }
            }
        }
        Err(code) => code,
    }
}

// ─────────────────────────────────────────────────────────
// Repair
// ─────────────────────────────────────────────────────────

/// Tryb naprawy: skan + diagnoza + redownload niezgodnych plików.
pub async fn run_repair(args: &CliArgs) -> i32 {
    if args.base_url.is_empty() {
        eprintln!("[BŁĄD] Wymagany --base-url (do pobrania manifestu i plików)");
        return 1;
    }

    let client_dir = PathBuf::from(&args.client_dir);
    let launcher_data = resolve_launcher_data(&client_dir, &args.launcher_data_dir);

    let api = match create_api_client(args) {
        Ok(c) => c,
        Err(code) => return code,
    };

    // Pobierz manifest
    tracing::info!("Pobieram manifest do naprawy...");
    let manifest = match api.fetch_manifest(&args.channel).await {
        Ok(m) => m,
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę pobrać manifestu: {}", e);
            return 30; // LCH_MANIFEST_FETCH_FAILED
        }
    };

    // Diagnoza
    let (diag, plan) = match repair::diagnose_installation(&manifest, &client_dir) {
        Ok((d, p)) => (d, p),
        Err(e) => {
            eprintln!("[BŁĄD] Diagnoza nie powiodła się: {}", e);
            return 31;
        }
    };

    println!("=== Raport naprawy ===");
    println!("Pliki OK:        {}", diag.ok_files.len());
    println!("Uszkodzone:      {}", diag.corrupted_files.len());
    println!("Brakujące:       {}", diag.missing_files.len());
    println!("Orphan:          {}", diag.orphan_files.len());
    println!("Do pobrania:     {} B", diag.total_repair_bytes);
    println!();

    if plan.is_up_to_date {
        println!("Instalacja jest kompletna — brak plików do naprawy.");
        return 0;
    }

    if args.dry_run {
        println!("[DRY-RUN] Plan naprawy:");
        println!("  Download: {} plików", plan.to_download.len());
        println!("  Replace:  {} plików", plan.to_replace.len());
        println!("  Delete:   {} plików", plan.to_delete.len());
        return 0;
    }

    // Aplikuj naprawę (identycznie jak update)
    let tx_id = uuid::Uuid::new_v4().to_string();
    let ctx = PatchContext::new(&client_dir, &launcher_data, &tx_id);
    if let Err(e) = ctx.init_dirs() {
        eprintln!("[BŁĄD] Nie mogę przygotować katalogów: {}", e);
        return 32;
    }

    let mut ok_count = 0u32;
    let mut fail_count = 0u32;

    for file_action in &plan.to_download {
        tracing::info!("Naprawa: {} ({} B)", file_action.path, file_action.size);

        match api.download_file(&file_action.url).await {
            Ok(data) => {
                match patcher::stage_file(
                    &ctx,
                    &file_action.path,
                    &data,
                    &file_action.expected_sha256,
                ) {
                    Ok(()) => {
                        if let Err(e) = patcher::apply_staged_file(&ctx, &file_action.path) {
                            eprintln!("  [BŁĄD] Nie mogę zastosować {}: {}", file_action.path, e);
                            fail_count += 1;
                        } else {
                            ok_count += 1;
                        }
                    }
                    Err(e) => {
                        eprintln!("  [BŁĄD] Weryfikacja {}: {}", file_action.path, e);
                        fail_count += 1;
                    }
                }
            }
            Err(e) => {
                eprintln!("  [BŁĄD] Pobieranie {}: {}", file_action.path, e);
                fail_count += 1;
            }
        }
    }

    println!();
    println!("Naprawa zakończona: {} OK, {} błędów", ok_count, fail_count);

    let _ = ctx.cleanup();

    if fail_count > 0 {
        33
    } else {
        0
    }
}

// ─────────────────────────────────────────────────────────
// Status
// ─────────────────────────────────────────────────────────

/// Pokaż installed_state.json.
pub fn run_status(args: &CliArgs) -> i32 {
    let client_dir = PathBuf::from(&args.client_dir);
    let launcher_data = resolve_launcher_data(&client_dir, &args.launcher_data_dir);
    let state_path = launcher_data.join("installed_state.json");

    if !state_path.exists() {
        eprintln!(
            "Brak pliku installed_state.json w: {}",
            state_path.display()
        );
        eprintln!("Uruchom 'launcher-cli update' aby utworzyć stan.");
        return 1;
    }

    match state::load_state(&state_path) {
        Ok(s) => {
            println!("{}", serde_json::to_string_pretty(&s).unwrap_or_default());
            0
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę wczytać state: {}", e);
            2
        }
    }
}

// ─────────────────────────────────────────────────────────
// Check version
// ─────────────────────────────────────────────────────────

/// Sprawdź wersję launchera na serwerze.
pub async fn run_check_version(args: &CliArgs) -> i32 {
    if args.base_url.is_empty() {
        eprintln!("[BŁĄD] Wymagany --base-url");
        return 1;
    }

    let api = match create_api_client(args) {
        Ok(c) => c,
        Err(code) => return code,
    };

    match api.check_launcher_version().await {
        Ok(ver) => {
            println!("Wersja serwera:  {}", ver.version);
            println!("Min. wersja:     {}", ver.min_version);
            println!("Wymagana:        {}", ver.required);
            println!("URL pobrania:    {}", ver.url);
            println!("Lokalna wersja:  {}", args.launcher_version);
            0
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę sprawdzić wersji: {}", e);
            11
        }
    }
}

// ─────────────────────────────────────────────────────────
// Compute hash
// ─────────────────────────────────────────────────────────

/// Oblicz filesHash z lokalnych plików (wymaga manifestu z API).
pub async fn run_compute_hash(args: &CliArgs) -> i32 {
    if args.base_url.is_empty() {
        eprintln!("[BŁĄD] Wymagany --base-url (do pobrania manifestu)");
        return 1;
    }

    let client_dir = PathBuf::from(&args.client_dir);

    let api = match create_api_client(args) {
        Ok(c) => c,
        Err(code) => return code,
    };

    let manifest = match api.fetch_manifest(&args.channel).await {
        Ok(m) => m,
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę pobrać manifestu: {}", e);
            return 30;
        }
    };

    match compute_files_hash(&manifest, &client_dir) {
        Ok(h) => {
            println!("{}", h);
            0
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę obliczyć filesHash: {}", e);
            20
        }
    }
}

// ─────────────────────────────────────────────────────────
// Wewnętrzne helpery
// ─────────────────────────────────────────────────────────

fn create_api_client(args: &CliArgs) -> Result<ApiClient, i32> {
    let config = ApiClientConfig {
        base_url: args.base_url.clone(),
        timeout_seconds: 30,
        max_retries: 3,
        user_agent: format!("TwojaGra-Launcher/{}", args.launcher_version),
        dev_mode: args.dev_mode,
    };

    ApiClient::new(config).map_err(|e| {
        eprintln!("[BŁĄD] Nie mogę utworzyć klienta API: {}", e);
        2
    })
}

fn resolve_launcher_data(client_dir: &Path, launcher_data_dir: &str) -> PathBuf {
    let p = PathBuf::from(launcher_data_dir);
    if p.is_absolute() {
        p
    } else {
        client_dir.join(p)
    }
}

/// Wewnętrzny flow aktualizacji: manifest → scan → plan → download → apply.
/// Zwraca manifest po udanej aktualizacji.
async fn run_update_flow(
    api: &ApiClient,
    args: &CliArgs,
    client_dir: &Path,
    launcher_data: &Path,
) -> Result<NormalizedManifest, i32> {
    // Sprawdź czy potrzebna recovery z poprzedniego update
    let state_path = launcher_data.join("installed_state.json");
    if state_path.exists() {
        if let Ok(mut existing_state) = state::load_state(&state_path) {
            if patcher::check_recovery_needed(&existing_state) {
                tracing::warn!("Wykryto przerwany update — uruchamiam recovery/rollback");
                let tx_id = existing_state.update_transaction.tx_id.clone();
                let ctx = PatchContext::new(client_dir, launcher_data, &tx_id);
                if let Err(e) = patcher::rollback(&ctx, &mut existing_state) {
                    tracing::error!("Rollback nie powiódł się: {}", e);
                    // Kontynuujemy mimo to — update może naprawić
                }
                let _ = ctx.cleanup();
            }
        }
    }

    // 1. Pobierz manifest
    tracing::info!("Pobieram manifest (channel={})...", args.channel);
    let manifest = api.fetch_manifest(&args.channel).await.map_err(|e| {
        eprintln!("[BŁĄD] Nie mogę pobrać manifestu: {}", e);
        match e {
            ApiError::RateLimited => 29, // LCH_API_RATE_LIMITED
            _ => 30,                     // LCH_MANIFEST_FETCH_FAILED
        }
    })?;

    tracing::info!(
        "Manifest: version={}, {} plików",
        manifest.version,
        manifest.files.len()
    );

    // 2. Skan lokalnych plików
    tracing::info!("Skanuję lokalne pliki...");
    let local_index = LocalFileIndex::scan_from_manifest(&manifest, client_dir).map_err(|e| {
        eprintln!("[BŁĄD] Skan plików nie powiódł się: {}", e);
        31i32
    })?;

    tracing::info!("Zeskanowano {} plików", local_index.files.len());

    // 3. Generuj plan aktualizacji
    let plan = planner::build_update_plan(&manifest, &local_index).map_err(|e| {
        eprintln!("[BŁĄD] Planner: {}", e);
        32i32
    })?;

    let summary = plan.summary();
    tracing::info!("{}", summary);

    if plan.is_up_to_date {
        tracing::info!("Klient jest aktualny — brak zmian do pobrania.");
        quarantine_player_runtime_leftovers(client_dir, launcher_data)?;

        return Ok(manifest);
    }

    if args.dry_run {
        println!("[DRY-RUN] Plan aktualizacji:");
        println!("  Download: {} plików", plan.to_download.len());
        println!("  Replace:  {} plików", plan.to_replace.len());
        println!("  Delete:   {} plików", plan.to_delete.len());
        println!("  Keep:     {} plików", plan.to_keep.len());
        for f in &plan.to_download {
            println!("    ↓ {} ({} B)", f.path, f.size);
        }
        for d in &plan.to_delete {
            println!("    ✕ {}", d.path);
        }
        return Ok(manifest);
    }

    // 4. Przygotuj transakcję update
    let tx_id = uuid::Uuid::new_v4().to_string();
    let ctx = PatchContext::new(client_dir, launcher_data, &tx_id);
    ctx.init_dirs().map_err(|e| {
        eprintln!("[BŁĄD] Przygotowanie katalogów: {}", e);
        33i32
    })?;

    // Utwórz/wczytaj state
    let mut installed_state = if state_path.exists() {
        state::load_state(&state_path).unwrap_or_else(|_| {
            InstalledState::new_minimal(
                uuid::Uuid::new_v4().to_string(),
                args.channel.clone(),
                client_dir.to_string_lossy().to_string(),
                args.launcher_version.clone(),
                args.base_url.clone(),
            )
        })
    } else {
        InstalledState::new_minimal(
            uuid::Uuid::new_v4().to_string(),
            args.channel.clone(),
            client_dir.to_string_lossy().to_string(),
            args.launcher_version.clone(),
            args.base_url.clone(),
        )
    };

    // Begin transaction
    let now_utc = chrono_utc_now();
    let staging_path = ctx.staging_dir.to_string_lossy().to_string();
    installed_state.update_transaction.begin(
        tx_id.clone(),
        manifest.version.clone(),
        manifest.manifest_id.clone(),
        now_utc,
        staging_path,
    );
    installed_state.update_transaction.status = UpdateTxStatus::Downloading;
    let _ = state::save_state(&installed_state, &state_path);

    // 5. Pobierz i stage pliki
    let total = plan.to_download.len();
    let mut staged_files: Vec<String> = Vec::new();

    for (i, file_action) in plan.to_download.iter().enumerate() {
        tracing::info!(
            "[{}/{}] Pobieram: {} ({} B)",
            i + 1,
            total,
            file_action.path,
            file_action.size
        );

        let data = api.download_file(&file_action.url).await.map_err(|e| {
            eprintln!(
                "[BŁĄD] Pobieranie {} nie powiodło się: {}",
                file_action.path, e
            );
            // Próba rollback
            let _ = patcher::rollback(&ctx, &mut installed_state);
            34i32
        })?;

        patcher::stage_file(&ctx, &file_action.path, &data, &file_action.expected_sha256).map_err(
            |e| {
                eprintln!("[BŁĄD] Weryfikacja {}: {}", file_action.path, e);
                let _ = patcher::rollback(&ctx, &mut installed_state);
                35i32
            },
        )?;

        staged_files.push(file_action.path.clone());
    }

    // 6. Weryfikacja — status = Verifying
    installed_state.update_transaction.status = UpdateTxStatus::Verifying;
    let _ = state::save_state(&installed_state, &state_path);

    // 7. Aplikuj zmiany
    installed_state.update_transaction.status = UpdateTxStatus::Applying;
    let _ = state::save_state(&installed_state, &state_path);

    if let Err(e) = patcher::apply_plan(&ctx, &plan, &staged_files, &mut installed_state) {
        eprintln!("[BŁĄD] Aplikowanie zmian nie powiodło się: {}", e);
        tracing::error!("Uruchamiam rollback po błędzie apply...");
        let _ = patcher::rollback(&ctx, &mut installed_state);
        return Err(36);
    }

    quarantine_player_runtime_leftovers(client_dir, launcher_data)?;

    // 8. Finalizuj
    installed_state.update_transaction.status = UpdateTxStatus::Finalizing;
    let _ = state::save_state(&installed_state, &state_path);

    // Aktualizuj managed index
    let now = chrono_utc_now();
    patcher::update_managed_index(&mut installed_state, &plan, &now);

    // Oblicz nowy filesHash po update
    let new_files_hash =
        compute_files_hash(&manifest, client_dir).unwrap_or_else(|_| String::new());

    // Zakończ transakcję
    installed_state.mark_success(
        manifest.version.clone(),
        manifest.manifest_id.clone(),
        new_files_hash,
        now,
    );
    let _ = state::save_state(&installed_state, &state_path);

    // Cleanup staging/backup
    let _ = ctx.cleanup();

    if !manifest.servers.is_empty() {
        tracing::info!(
            "Pomijam generowanie serverlist w katalogu klienta; player runtime używa sealed config i API ticket"
        );
    }

    tracing::info!("Aktualizacja zakończona pomyślnie!");
    Ok(manifest)
}

/// Pobierz launch-token z API.
async fn request_token(
    api: &ApiClient,
    args: &CliArgs,
    manifest: &NormalizedManifest,
    files_hash: &str,
) -> Result<String, i32> {
    let request = LaunchTokenRequest {
        launcher_version: args.launcher_version.clone(),
        files_hash: files_hash.to_string(),
        channel: args.channel.clone(),
        manifest_version: manifest.version.clone(),
        nonce: None,
        challenge_response: None,
    };

    match api.request_launch_token(&request).await {
        Ok(resp) => {
            tracing::info!("Token otrzymany (TTL: {}s)", resp.expires_in_seconds);
            Ok(resp.token)
        }
        Err(ApiError::TokenRejected { error, message }) => {
            eprintln!("[BŁĄD] Token odrzucony: {} — {}", error, message);
            Err(40) // LCH_TOKEN_REJECTED
        }
        Err(ApiError::RateLimited) => {
            eprintln!("[BŁĄD] Zbyt wiele żądań tokena — spróbuj ponownie za chwilę.");
            Err(29) // LCH_API_RATE_LIMITED
        }
        Err(e) => {
            eprintln!("[BŁĄD] Nie mogę pobrać tokena: {}", e);
            Err(41) // LCH_TOKEN_FETCH_FAILED
        }
    }
}

fn quarantine_player_runtime_leftovers(
    client_dir: &Path,
    launcher_data: &Path,
) -> Result<Vec<String>, i32> {
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
    fs::create_dir_all(&quarantine_dir).map_err(|e| {
        eprintln!("[BŁĄD] Nie mogę utworzyć kwarantanny player runtime: {e}");
        37
    })?;

    let mut moved = Vec::new();
    for rel in candidates {
        let src = client_dir.join(&rel);
        if !src.exists() {
            continue;
        }
        let dst = quarantine_dir.join(&rel);
        if let Some(parent) = dst.parent() {
            fs::create_dir_all(parent).map_err(|e| {
                eprintln!(
                    "[BŁĄD] Nie mogę przygotować katalogu kwarantanny dla {}: {e}",
                    rel.display()
                );
                37
            })?;
        }
        fs::rename(&src, &dst).map_err(|e| {
            eprintln!(
                "[BŁĄD] Nie mogę przenieść legacy/dev pliku {} do kwarantanny: {e}",
                rel.display()
            );
            37
        })?;
        moved.push(rel.to_string_lossy().to_string());
    }

    if !moved.is_empty() {
        tracing::warn!(
            "Player runtime cleanup quarantined {} leftover files: {:?}",
            moved.len(),
            moved
        );
    }

    Ok(moved)
}

/// Prosta implementacja UTC now (bez dodatkowej zależności od chrono).
fn chrono_utc_now() -> String {
    // Używamy systemowego czasu — format ISO 8601
    let now = std::time::SystemTime::now();
    let duration = now
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default();
    let secs = duration.as_secs();

    // Prosty konwerter sekund unix → ISO 8601 (wystarczający na potrzeby state)
    // Format: "2026-03-03T12:00:00Z"
    let days = secs / 86400;
    let time_of_day = secs % 86400;
    let hours = time_of_day / 3600;
    let minutes = (time_of_day % 3600) / 60;
    let seconds = time_of_day % 60;

    // Oblicz rok/miesiąc/dzień z dni od epoch
    let (year, month, day) = days_to_ymd(days);

    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        year, month, day, hours, minutes, seconds
    )
}

/// Konwertuje liczbę dni od Unix epoch na (rok, miesiąc, dzień).
fn days_to_ymd(days: u64) -> (u64, u64, u64) {
    // Algorytm: civil_from_days (Howard Hinnant)
    let z = days as i64 + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = (z - era * 146097) as u64;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let year = if m <= 2 { y + 1 } else { y };
    (year as u64, m, d)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_chrono_utc_now_format() {
        let now = chrono_utc_now();
        // Powinien mieć format ISO 8601
        assert!(now.ends_with('Z'));
        assert_eq!(now.len(), 20); // "2026-03-03T12:00:00Z"
        assert_eq!(&now[4..5], "-");
        assert_eq!(&now[7..8], "-");
        assert_eq!(&now[10..11], "T");
        assert_eq!(&now[13..14], ":");
        assert_eq!(&now[16..17], ":");
    }

    #[test]
    fn test_days_to_ymd_epoch() {
        let (y, m, d) = days_to_ymd(0);
        assert_eq!((y, m, d), (1970, 1, 1));
    }

    #[test]
    fn test_days_to_ymd_known_date() {
        // 2026-03-03 = dzień 20515 od epoch
        let (y, m, d) = days_to_ymd(20515);
        assert_eq!((y, m, d), (2026, 3, 3));
    }

    #[test]
    fn test_resolve_launcher_data_relative() {
        let client_dir = PathBuf::from("/opt/game");
        let result = resolve_launcher_data(&client_dir, ".launcher");
        assert_eq!(result, PathBuf::from("/opt/game/.launcher"));
    }

    #[test]
    fn test_resolve_launcher_data_absolute() {
        let client_dir = PathBuf::from("/opt/game");
        let result = resolve_launcher_data(&client_dir, "/var/launcher");
        assert_eq!(result, PathBuf::from("/var/launcher"));
    }
}
