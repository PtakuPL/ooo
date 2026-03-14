//! Stan aplikacji współdzielony między komendami Tauri.

use std::path::PathBuf;
use std::sync::Mutex;

use common_models::installed_state::InstalledState;
use common_models::launcher_config::LauncherConfig;

/// Globalny stan launchera — zarządzany przez `tauri::manage()`.
pub struct AppState {
    pub inner: Mutex<AppStateInner>,
}

pub struct AppStateInner {
    /// Ścieżka katalogu klienta gry.
    pub client_dir: PathBuf,
    /// Ścieżka danych launchera (.launcher/).
    pub launcher_data_dir: PathBuf,
    /// Bazowy URL API.
    pub api_base_url: String,
    /// Kanał: "stable", "test", "dev".
    pub channel: String,
    /// Język interfejsu launchera.
    pub language: String,
    /// Wersja launchera.
    pub launcher_version: String,
    /// Załadowany stan instalacji (jeśli istnieje).
    pub installed_state: Option<InstalledState>,
    /// Czy aktualizacja jest w trakcie (zapobiega podwójnemu start).
    pub update_in_progress: bool,
    /// Tryb deweloperski — akceptuj self-signed certy.
    pub dev_mode: bool,
    /// Klucz publiczny Ed25519 do weryfikacji podpisu manifestu (hex).
    pub signature_public_key: Option<String>,
    /// Ostatnio załadowany config launchera.
    pub config: LauncherConfig,
    /// Ścieżka do `launcher_config.json` używana do zapisu ustawień.
    pub config_path: PathBuf,
    /// Token jednorazowy przekazany z WWW -> launcher przy starcie procesu.
    pub pending_account_sync_token: Option<String>,
}

impl AppState {
    pub fn new(pending_account_sync_token: Option<String>) -> Self {
        let exe_dir = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|d| d.to_path_buf()))
            .unwrap_or_else(|| PathBuf::from("."));

        // Próba załadowania launcher_config.json (obok exe lub katalog wyżej)
        let (config, config_path) =
            LauncherConfig::discover_with_path(&exe_dir).unwrap_or_else(|e| {
                tracing::warn!(
                    "Nie udało się załadować launcher_config.json: {e} — domyślne wartości"
                );
                (
                    LauncherConfig::default(),
                    exe_dir.join("launcher_config.json"),
                )
            });

        let launcher_data = exe_dir.join(&config.launcher_data_dir);
        let client_dir = exe_dir.join(&config.client_dir);
        let api_base_url = config.api_base_url.clone();
        let channel = config.channel.clone();
        let language = config.language.clone();
        let dev_mode = config.dev_mode;
        let signature_public_key = config.manifest_public_key.clone();

        Self {
            inner: Mutex::new(AppStateInner {
                client_dir,
                launcher_data_dir: launcher_data,
                api_base_url,
                channel,
                language,
                launcher_version: env!("CARGO_PKG_VERSION").to_string(),
                installed_state: None,
                update_in_progress: false,
                dev_mode,
                signature_public_key,
                config,
                config_path,
                pending_account_sync_token,
            }),
        }
    }
}
