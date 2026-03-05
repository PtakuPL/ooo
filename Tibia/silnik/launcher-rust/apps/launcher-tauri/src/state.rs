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
    /// Wersja launchera.
    pub launcher_version: String,
    /// Załadowany stan instalacji (jeśli istnieje).
    pub installed_state: Option<InstalledState>,
    /// Czy aktualizacja jest w trakcie (zapobiega podwójnemu start).
    pub update_in_progress: bool,
    /// Tryb deweloperski — akceptuj self-signed certy.
    pub dev_mode: bool,
}

impl AppState {
    pub fn new() -> Self {
        let exe_dir = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|d| d.to_path_buf()))
            .unwrap_or_else(|| PathBuf::from("."));

        // Próba załadowania launcher_config.json (obok exe lub katalog wyżej)
        let config = LauncherConfig::discover(&exe_dir).unwrap_or_else(|e| {
            tracing::warn!("Nie udało się załadować launcher_config.json: {e} — domyślne wartości");
            LauncherConfig::default()
        });

        let launcher_data = exe_dir.join(&config.launcher_data_dir);
        let client_dir = exe_dir.join(&config.client_dir);

        Self {
            inner: Mutex::new(AppStateInner {
                client_dir,
                launcher_data_dir: launcher_data,
                api_base_url: config.api_base_url,
                channel: config.channel,
                launcher_version: env!("CARGO_PKG_VERSION").to_string(),
                installed_state: None,
                update_in_progress: false,
                dev_mode: config.dev_mode,
            }),
        }
    }
}
