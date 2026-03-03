//! Stan aplikacji współdzielony między komendami Tauri.

use std::path::PathBuf;
use std::sync::Mutex;

use common_models::installed_state::InstalledState;

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
}

impl AppState {
    pub fn new() -> Self {
        // Domyślne wartości — nadpisywane po załadowaniu konfiguracji
        let exe_dir = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|d| d.to_path_buf()))
            .unwrap_or_else(|| PathBuf::from("."));

        let launcher_data = exe_dir.join(".launcher");
        let client_dir = exe_dir.clone();

        Self {
            inner: Mutex::new(AppStateInner {
                client_dir,
                launcher_data_dir: launcher_data,
                api_base_url: "https://api.serwercanary.pl/client/".to_string(),
                channel: "stable".to_string(),
                launcher_version: env!("CARGO_PKG_VERSION").to_string(),
                installed_state: None,
                update_in_progress: false,
            }),
        }
    }
}
