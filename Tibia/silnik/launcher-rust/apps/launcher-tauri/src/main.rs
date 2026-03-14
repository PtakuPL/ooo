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

    let lock_name = if cfg!(target_os = "windows") { "launcher.lock" } else { ".launcher.lock" };
    exe_dir.join(launcher_data_dir).join(lock_name)
}

fn pending_account_sync_path() -> PathBuf {
    let lock_path = launcher_lock_path();
    let base_dir = lock_path
        .parent()
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from("."));
    base_dir.join("pending_account_sync_token.txt")
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

    // A2: Hide lock file on Windows
    #[cfg(target_os = "windows")]
    {
        use std::os::windows::ffi::OsStrExt;
        let wide_path: Vec<u16> = lock_path.as_os_str().encode_wide().chain(std::iter::once(0)).collect();
        unsafe {
            #[link(name = "kernel32")]
            extern "system" { fn SetFileAttributesW(path: *const u16, attr: u32) -> i32; }
            SetFileAttributesW(wide_path.as_ptr(), 0x02); // FILE_ATTRIBUTE_HIDDEN
        }
    }

    Ok(AppLock { path: lock_path })
}

fn parse_account_sync_token_from_args(args: &[String]) -> Option<String> {
    for arg in args.iter().skip(1) {
        let trimmed = arg.trim();
        if trimmed.is_empty() {
            continue;
        }
        let (_, rest) = trimmed.split_once("://")?;
        let (host_and_path, query) = rest.split_once('?')?;
        if !host_and_path.eq_ignore_ascii_case("account-sync") {
            continue;
        }
        for pair in query.split('&') {
            let (key, value) = pair.split_once('=')?;
            if key != "token" {
                continue;
            }
            let token = value.trim();
            if token.len() == 64 && token.chars().all(|c| c.is_ascii_hexdigit()) {
                return Some(token.to_ascii_lowercase());
            }
        }
    }
    None
}

fn write_pending_account_sync_token(token: &str) -> Result<(), String> {
    let path = pending_account_sync_path();
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)
            .map_err(|e| format!("Nie mozna utworzyc katalogu pending sync: {e}"))?;
    }
    std::fs::write(&path, token)
        .map_err(|e| format!("Nie mozna zapisac pending sync token: {e}"))?;
    Ok(())
}

#[cfg(target_os = "windows")]
fn best_effort_register_url_scheme() {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    const HKEY_CURRENT_USER: isize = 0x80000001_u32 as i32 as isize;
    const KEY_WRITE: u32 = 0x20006;
    const REG_SZ: u32 = 1;
    const SCHEME_KEY: &str = r"Software\Classes\launcher";
    const COMMAND_KEY: &str = r"Software\Classes\launcher\shell\open\command";

    #[link(name = "advapi32")]
    extern "system" {
        fn RegCreateKeyExW(
            hKey: isize,
            lpSubKey: *const u16,
            reserved: u32,
            lpClass: *const u16,
            dwOptions: u32,
            samDesired: u32,
            lpSecurityAttributes: *mut u8,
            phkResult: *mut isize,
            lpdwDisposition: *mut u32,
        ) -> i32;
        fn RegSetValueExW(
            hKey: isize,
            lpValueName: *const u16,
            reserved: u32,
            dwType: u32,
            lpData: *const u8,
            cbData: u32,
        ) -> i32;
        fn RegCloseKey(hKey: isize) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    fn set_string_value(hkey: isize, name: &str, value: &str) -> Result<(), String> {
        let name_w = to_wide(name);
        let value_w = to_wide(value);
        let result = unsafe {
            RegSetValueExW(
                hkey,
                name_w.as_ptr(),
                0,
                REG_SZ,
                value_w.as_ptr() as *const u8,
                (value_w.len() * 2) as u32,
            )
        };
        if result != 0 {
            return Err(format!("RegSetValueExW({name}) failed: {result}"));
        }
        Ok(())
    }

    fn create_key(path: &str) -> Result<isize, String> {
        let key_w = to_wide(path);
        let mut hkey: isize = 0;
        let mut disposition: u32 = 0;
        let result = unsafe {
            RegCreateKeyExW(
                HKEY_CURRENT_USER,
                key_w.as_ptr(),
                0,
                std::ptr::null(),
                0,
                KEY_WRITE,
                std::ptr::null_mut(),
                &mut hkey,
                &mut disposition,
            )
        };
        if result != 0 {
            return Err(format!("RegCreateKeyExW({path}) failed: {result}"));
        }
        Ok(hkey)
    }

    let Ok(exe_path) = std::env::current_exe() else {
        return;
    };
    let command = format!("\"{}\" \"%1\"", exe_path.display());

    let scheme_key = match create_key(SCHEME_KEY) {
        Ok(key) => key,
        Err(err) => {
            tracing::warn!("Nie udalo sie zarejestrowac URL scheme launcher: {}", err);
            return;
        }
    };

    let res = (|| -> Result<(), String> {
        set_string_value(scheme_key, "", "URL:RedDaxe Launcher Protocol")?;
        set_string_value(scheme_key, "URL Protocol", "")?;
        Ok(())
    })();
    unsafe {
        RegCloseKey(scheme_key);
    }
    if let Err(err) = res {
        tracing::warn!("Nie udalo sie zapisac URL scheme launcher: {}", err);
        return;
    }

    let command_key = match create_key(COMMAND_KEY) {
        Ok(key) => key,
        Err(err) => {
            tracing::warn!(
                "Nie udalo sie zarejestrowac komendy URL scheme launcher: {}",
                err
            );
            return;
        }
    };
    let res = set_string_value(command_key, "", &command);
    unsafe {
        RegCloseKey(command_key);
    }
    if let Err(err) = res {
        tracing::warn!("Nie udalo sie zapisac komendy URL scheme launcher: {}", err);
    }
}

#[cfg(not(target_os = "windows"))]
fn best_effort_register_url_scheme() {}

fn main() {
    // Logi: LAUNCHER_LOG=debug lub domyślnie info
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::try_from_env("LAUNCHER_LOG").unwrap_or_else(|_| EnvFilter::new("info")),
        )
        .init();

    tracing::info!("RedDaxe.pl Launcher v{}", env!("CARGO_PKG_VERSION"));

    let args: Vec<String> = std::env::args().collect();
    let startup_account_sync_token = parse_account_sync_token_from_args(&args);

    let _app_lock = match acquire_app_lock() {
        Ok(lock) => lock,
        Err(err) => {
            if let Some(token) = startup_account_sync_token.as_deref() {
                match write_pending_account_sync_token(token) {
                    Ok(()) => {
                        tracing::info!(
                            "Launcher juz dziala — zapisano pending WWW sync token dla aktywnej instancji"
                        );
                        std::process::exit(0);
                    }
                    Err(write_err) => {
                        tracing::error!("{write_err}");
                        eprintln!("{write_err}");
                        std::process::exit(3);
                    }
                }
            }
            tracing::error!("{err}");
            eprintln!("{err}");
            std::process::exit(2);
        }
    };

    best_effort_register_url_scheme();

    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(state::AppState::new(startup_account_sync_token))
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
            commands::consume_pending_account_sync,
            commands::refresh_launcher_account_context,
            commands::login_launcher_account,
            commands::register_launcher_account,
            commands::report_error,
            commands::uninstall_game_files,
            commands::uninstall_launcher,
            commands::get_bootstrap_language,
        ])
        .run(tauri::generate_context!())
        .expect("Błąd uruchamiania Tauri");
}
