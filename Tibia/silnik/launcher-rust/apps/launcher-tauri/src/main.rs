//! Launcher Tauri — entry point.
//!
//! LR-031: App Tauri startujący na Windows/Linux.
//! Rejestruje komendy backendu i startuje okno.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod state;

use tracing_subscriber::EnvFilter;

fn main() {
    // Logi: LAUNCHER_LOG=debug lub domyślnie info
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_env("LAUNCHER_LOG").unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    tracing::info!("SerwerCanary Launcher v{}", env!("CARGO_PKG_VERSION"));

    tauri::Builder::default()
        .manage(state::AppState::new())
        .invoke_handler(tauri::generate_handler![
            commands::get_status,
            commands::check_for_updates,
            commands::start_update,
            commands::launch_game,
            commands::repair_installation,
            commands::get_installation_info,
            commands::change_channel,
            commands::export_logs,
            commands::get_installer_catalog,
            commands::download_and_verify_artifact,
            commands::check_launcher_update,
            commands::perform_self_update,
        ])
        .run(tauri::generate_context!())
        .expect("Błąd uruchamiania Tauri");
}
