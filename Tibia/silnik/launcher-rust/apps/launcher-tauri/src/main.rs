//! Launcher Tauri — entry point.
//!
//! LR-031: App Tauri startujący na Windows/Linux.
//! Rejestruje komendy backendu i startuje okno.

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;
mod state;

use common_models::launcher_config::LauncherConfig;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::time::Duration;
use tracing_subscriber::EnvFilter;

struct AppLock {
    path: PathBuf,
}

impl Drop for AppLock {
    fn drop(&mut self) {
        if let Err(e) = std::fs::remove_file(&self.path) {
            tracing::warn!("Nie udalo sie usunac lock-file {}: {}", self.path.display(), e);
        }
    }
}

fn launcher_lock_path() -> PathBuf {
    let exe_dir = std::env::current_exe()
        .ok()
        .and_then(|p| p.parent().map(|d| d.to_path_buf()))
        .unwrap_or_else(|| PathBuf::from("."));

    let launcher_data_dir = LauncherConfig::discover(&exe_dir)
        .map(|cfg| cfg.launcher_data_dir)
        .unwrap_or_else(|_| "launcher_data".to_string());

    exe_dir.join(launcher_data_dir).join("launcher.lock")
}

fn parse_lock_pid(content: &str) -> Option<u32> {
    for line in content.lines() {
        if let Some(pid) = line.strip_prefix("pid=") {
            if let Ok(parsed) = pid.trim().parse::<u32>() {
                return Some(parsed);
            }
        }
    }
    None
}

fn is_process_alive(pid: u32) -> bool {
    #[cfg(target_os = "linux")]
    {
        Path::new(&format!("/proc/{pid}")).exists()
    }

    #[cfg(not(target_os = "linux"))]
    {
        let _ = pid;
        false
    }
}

fn lock_older_than(path: &Path, max_age: Duration) -> bool {
    std::fs::metadata(path)
        .ok()
        .and_then(|m| m.modified().ok())
        .and_then(|mtime| mtime.elapsed().ok())
        .map(|age| age > max_age)
        .unwrap_or(false)
}

fn acquire_app_lock() -> Result<AppLock, String> {
    let lock_path = launcher_lock_path();

    if let Some(parent) = lock_path.parent() {
        std::fs::create_dir_all(parent)
            .map_err(|e| format!("Nie mozna utworzyc katalogu lock-file: {e}"))?;
    }

    if lock_path.exists() {
        let lock_content = std::fs::read_to_string(&lock_path).unwrap_or_default();
        let lock_pid = parse_lock_pid(&lock_content);

        let stale_by_dead_pid = lock_pid.map(|pid| !is_process_alive(pid)).unwrap_or(false);
        let stale_by_age = lock_older_than(&lock_path, Duration::from_secs(12 * 60 * 60));

        if stale_by_dead_pid || stale_by_age {
            tracing::warn!(
                "Wykryto stale lock-file (pid={:?}, stale_by_age={}), usuwam: {}",
                lock_pid,
                stale_by_age,
                lock_path.display()
            );
            let _ = std::fs::remove_file(&lock_path);
        } else {
            return Err(format!(
                "LCH_SINGLE_INSTANCE_LOCKED: launcher jest juz uruchomiony (lock: {})",
                lock_path.display()
            ));
        }
    }

    let mut lock_file = OpenOptions::new()
        .create_new(true)
        .write(true)
        .open(&lock_path)
        .map_err(|e| format!("Nie mozna utworzyc lock-file: {e}"))?;

    let pid = std::process::id();
    writeln!(lock_file, "pid={pid}")
        .map_err(|e| format!("Nie mozna zapisac lock-file: {e}"))?;

    Ok(AppLock { path: lock_path })
}

fn main() {
    // Logi: LAUNCHER_LOG=debug lub domyślnie info
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_env("LAUNCHER_LOG").unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    tracing::info!("SerwerCanary Launcher v{}", env!("CARGO_PKG_VERSION"));

    let _app_lock = match acquire_app_lock() {
        Ok(lock) => lock,
        Err(err) => {
            tracing::error!("{err}");
            eprintln!("{err}");
            std::process::exit(2);
        }
    };

    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(state::AppState::new())
        .invoke_handler(tauri::generate_handler![
            commands::get_status,
            commands::check_for_updates,
            commands::start_update,
            commands::pre_launch_check,
            commands::repair_tampered_critical_files,
            commands::launch_game,
            commands::repair_installation,
            commands::get_installation_info,
            commands::change_channel,
            commands::export_logs,
            commands::get_installer_catalog,
            commands::get_language_packs,
            commands::download_language_pack,
            commands::list_installed_language_packs,
            commands::download_and_verify_artifact,
            commands::check_launcher_update,
            commands::perform_self_update,
            commands::get_server_status,
            commands::health_check_critical_endpoints,
            commands::build_create_character_url,
            commands::refresh_launcher_account_context,
            commands::login_launcher_account,
            commands::register_launcher_account,
            commands::report_error,
            commands::uninstall_game_files,
            commands::uninstall_launcher,
        ])
        .run(tauri::generate_context!())
        .expect("Błąd uruchamiania Tauri");
}
