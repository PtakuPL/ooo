//! Launcher Helper — self-update binary (LR-047).
//!
//! Flow:
//! 1. Launcher pobiera nową wersję do staging/
//! 2. Launcher uruchamia LauncherHelper z parametrami:
//!    --pid <PID_launchera>
//!    --source <ścieżka_nowej_binarki>
//!    --target <ścieżka_docelowa_launchera>
//!    --backup <ścieżka_backup>
//!    --restart
//! 3. Helper czeka na zamknięcie launchera (poll PID)
//! 4. Helper kopiuje backup starego launchera
//! 5. Helper podmienia binarkę
//! 6. Helper restartuje launcher
//! 7. Helper kończy się

use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{Duration, Instant};

use sha2::{Digest, Sha256};

/// Konfiguracja operacji self-update (parsowana z CLI args).
#[derive(Debug, Clone)]
pub struct UpdateConfig {
    /// PID procesu launchera do odczekania zamknięcia.
    pub launcher_pid: Option<u32>,
    /// Ścieżka nowej binarki (staging).
    pub source_path: PathBuf,
    /// Ścieżka docelowa launchera.
    pub target_path: PathBuf,
    /// Ścieżka backup starego launchera.
    pub backup_path: PathBuf,
    /// Czy restartować launcher po podmiance.
    pub restart: bool,
    /// Opcjonalny oczekiwany SHA-256 nowej binarki.
    pub expected_sha256: Option<String>,
    /// Maksymalny czas oczekiwania na zamknięcie launchera (sekundy).
    pub wait_timeout_secs: u64,
}

/// Błędy helpera.
#[derive(Debug)]
pub enum HelperError {
    /// Launcher nie zamknął się w timeout.
    LauncherStillRunning(u32),
    /// Nie znaleziono pliku źródłowego.
    SourceNotFound(PathBuf),
    /// Hash mismatch.
    HashMismatch { expected: String, actual: String },
    /// Backup nie powiódł się.
    BackupFailed(String),
    /// Podmiana nie powiodła się.
    ReplaceFailed(String),
    /// Restart nie powiódł się.
    RestartFailed(String),
    /// Rollback nie powiódł się.
    RollbackFailed(String),
    /// Błąd I/O.
    Io(std::io::Error),
}

impl std::fmt::Display for HelperError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::LauncherStillRunning(pid) => {
                write!(f, "Launcher (PID {}) still running after timeout", pid)
            }
            Self::SourceNotFound(p) => write!(f, "Source file not found: {}", p.display()),
            Self::HashMismatch { expected, actual } => {
                write!(f, "Hash mismatch: expected {}, got {}", expected, actual)
            }
            Self::BackupFailed(e) => write!(f, "Backup failed: {}", e),
            Self::ReplaceFailed(e) => write!(f, "Replace failed: {}", e),
            Self::RestartFailed(e) => write!(f, "Restart failed: {}", e),
            Self::RollbackFailed(e) => write!(f, "Rollback failed: {}", e),
            Self::Io(e) => write!(f, "I/O error: {}", e),
        }
    }
}

impl From<std::io::Error> for HelperError {
    fn from(e: std::io::Error) -> Self {
        Self::Io(e)
    }
}

/// Czeka aż proces o danym PID zakończy się.
fn wait_for_process_exit(pid: u32, timeout: Duration) -> Result<(), HelperError> {
    let start = Instant::now();
    let poll_interval = Duration::from_millis(250);

    tracing::info!("Waiting for launcher PID {} to exit (timeout: {:?})", pid, timeout);

    loop {
        if !is_process_running(pid) {
            tracing::info!("Launcher PID {} has exited", pid);
            return Ok(());
        }

        if start.elapsed() > timeout {
            return Err(HelperError::LauncherStillRunning(pid));
        }

        std::thread::sleep(poll_interval);
    }
}

/// Sprawdza czy proces o danym PID jest aktywny.
#[cfg(unix)]
fn is_process_running(pid: u32) -> bool {
    // Na Linuxie: kill(pid, 0) zwraca 0 jeśli proces istnieje
    unsafe { libc_kill(pid as i32, 0) == 0 }
}

#[cfg(unix)]
extern "C" {
    fn kill(pid: i32, sig: i32) -> i32;
}

#[cfg(unix)]
unsafe fn libc_kill(pid: i32, sig: i32) -> i32 {
    unsafe { kill(pid, sig) }
}

#[cfg(windows)]
fn is_process_running(pid: u32) -> bool {
    // Na Windows: próba otwarcia procesu (simplyfikacja — w produkcji użyj WinAPI)
    // Tu uproszczony poll z /proc-like podejściem
    use std::process::Command;
    Command::new("tasklist")
        .args(["/FI", &format!("PID eq {}", pid), "/NH"])
        .output()
        .map(|o| {
            let output = String::from_utf8_lossy(&o.stdout);
            output.contains(&pid.to_string())
        })
        .unwrap_or(false)
}

#[cfg(not(any(unix, windows)))]
fn is_process_running(_pid: u32) -> bool {
    false
}

/// Oblicza SHA-256 pliku.
fn sha256_file(path: &Path) -> Result<String, std::io::Error> {
    let data = std::fs::read(path)?;
    let mut hasher = Sha256::new();
    hasher.update(&data);
    Ok(format!("{:x}", hasher.finalize()))
}

/// Wykonuje pełny flow self-update.
pub fn execute_self_update(config: &UpdateConfig) -> Result<(), HelperError> {
    tracing::info!("=== Launcher Helper: Self-Update Start ===");
    tracing::info!("Source: {}", config.source_path.display());
    tracing::info!("Target: {}", config.target_path.display());
    tracing::info!("Backup: {}", config.backup_path.display());

    // 1. Czekaj na zamknięcie launchera
    if let Some(pid) = config.launcher_pid {
        wait_for_process_exit(pid, Duration::from_secs(config.wait_timeout_secs))?;
    }

    // Krótka pauza po zamknięciu (zwolnienie locków na pliku)
    std::thread::sleep(Duration::from_millis(500));

    // 2. Sprawdź czy plik źródłowy istnieje
    if !config.source_path.exists() {
        return Err(HelperError::SourceNotFound(config.source_path.clone()));
    }

    // 3. Weryfikuj SHA-256 (jeśli podany)
    if let Some(expected) = &config.expected_sha256 {
        let actual = sha256_file(&config.source_path)?;
        if !actual.eq_ignore_ascii_case(expected) {
            return Err(HelperError::HashMismatch {
                expected: expected.clone(),
                actual,
            });
        }
        tracing::info!("SHA-256 verification: OK");
    }

    // 4. Backup starego launchera
    if config.target_path.exists() {
        if let Some(parent) = config.backup_path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| {
                HelperError::BackupFailed(format!("Cannot create backup dir: {}", e))
            })?;
        }
        std::fs::copy(&config.target_path, &config.backup_path).map_err(|e| {
            HelperError::BackupFailed(format!(
                "Cannot copy {} -> {}: {}",
                config.target_path.display(),
                config.backup_path.display(),
                e
            ))
        })?;
        tracing::info!("Backup created: {}", config.backup_path.display());
    }

    // 5. Podmień binarkę
    //    Na Windows: najpierw usuń target, potem skopiuj
    //    Na Linux: rename powinien działać (atomowo w obrębie jednego FS)
    match replace_binary(&config.source_path, &config.target_path) {
        Ok(()) => {
            tracing::info!("Binary replaced successfully");
        }
        Err(e) => {
            // Rollback: przywróć backup
            tracing::error!("Replace failed: {} — attempting rollback", e);
            if config.backup_path.exists() {
                if let Err(rb_err) = std::fs::copy(&config.backup_path, &config.target_path) {
                    return Err(HelperError::RollbackFailed(format!(
                        "Replace failed ({}) AND rollback failed ({})",
                        e, rb_err
                    )));
                }
                tracing::info!("Rollback successful");
            }
            return Err(HelperError::ReplaceFailed(e.to_string()));
        }
    }

    // 6. Ustaw uprawnienia wykonywalności (Linux/macOS)
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        if let Err(e) = std::fs::set_permissions(
            &config.target_path,
            std::fs::Permissions::from_mode(0o755),
        ) {
            tracing::warn!("Cannot set executable permission: {}", e);
        }
    }

    // 7. Restart launcher (jeśli żądany)
    if config.restart {
        tracing::info!("Restarting launcher: {}", config.target_path.display());
        let result = Command::new(&config.target_path)
            .spawn();

        match result {
            Ok(child) => {
                tracing::info!("Launcher restarted (PID: {})", child.id());
            }
            Err(e) => {
                return Err(HelperError::RestartFailed(format!(
                    "Cannot start {}: {}",
                    config.target_path.display(),
                    e
                )));
            }
        }
    }

    // 8. Zapisz wynik do pliku statusu
    let status_path = config.backup_path.with_extension("update_status.json");
    let status_json = serde_json::json!({
        "result": "success",
        "source": config.source_path.to_string_lossy(),
        "target": config.target_path.to_string_lossy(),
        "backup": config.backup_path.to_string_lossy(),
        "timestamp": chrono_utc_now(),
    });
    if let Err(e) = std::fs::write(&status_path, serde_json::to_string_pretty(&status_json).unwrap_or_default()) {
        tracing::warn!("Cannot write update status: {}", e);
    }

    tracing::info!("=== Launcher Helper: Self-Update Complete ===");
    Ok(())
}

/// Podmiana binarki: kopiuje source -> target.
fn replace_binary(source: &Path, target: &Path) -> Result<(), std::io::Error> {
    // Na systemach Unix: rename jest atomowy (w obrębie tego samego FS)
    // Na Windows: nie jest, ale copy + delete jest bezpieczne
    #[cfg(unix)]
    {
        // Najpierw próbujemy rename (atomowo)
        match std::fs::rename(source, target) {
            Ok(()) => return Ok(()),
            Err(_) => {
                // Różne filesystemy — fallback na copy
                std::fs::copy(source, target)?;
                let _ = std::fs::remove_file(source);
                return Ok(());
            }
        }
    }

    #[cfg(not(unix))]
    {
        // Windows: usuń target (może być locked), skopiuj source -> target
        if target.exists() {
            std::fs::remove_file(target)?;
        }
        std::fs::copy(source, target)?;
        let _ = std::fs::remove_file(source);
        Ok(())
    }
}

/// Howard Hinnant algorithm — UTC timestamp bez chrono.
fn chrono_utc_now() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};

    let secs = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs();

    let days = (secs / 86400) as i64;
    let time_of_day = secs % 86400;

    let z = days + 719468;
    let era = if z >= 0 { z } else { z - 146096 } / 146097;
    let doe = (z - era * 146097) as u32;
    let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    let y = yoe as i64 + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = if m <= 2 { y + 1 } else { y };

    let hh = time_of_day / 3600;
    let mm = (time_of_day % 3600) / 60;
    let ss = time_of_day % 60;

    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        y, m, d, hh, mm, ss
    )
}

/// Parsuje argumenty CLI.
pub fn parse_args(args: &[String]) -> Result<UpdateConfig, String> {
    let mut config = UpdateConfig {
        launcher_pid: None,
        source_path: PathBuf::new(),
        target_path: PathBuf::new(),
        backup_path: PathBuf::new(),
        restart: false,
        expected_sha256: None,
        wait_timeout_secs: 30,
    };

    let mut i = 0;
    while i < args.len() {
        match args[i].as_str() {
            "--pid" => {
                i += 1;
                config.launcher_pid = Some(
                    args.get(i)
                        .ok_or("--pid requires a value")?
                        .parse()
                        .map_err(|_| "--pid must be a number")?,
                );
            }
            "--source" => {
                i += 1;
                config.source_path = PathBuf::from(
                    args.get(i).ok_or("--source requires a value")?,
                );
            }
            "--target" => {
                i += 1;
                config.target_path = PathBuf::from(
                    args.get(i).ok_or("--target requires a value")?,
                );
            }
            "--backup" => {
                i += 1;
                config.backup_path = PathBuf::from(
                    args.get(i).ok_or("--backup requires a value")?,
                );
            }
            "--sha256" => {
                i += 1;
                config.expected_sha256 = Some(
                    args.get(i).ok_or("--sha256 requires a value")?.clone(),
                );
            }
            "--timeout" => {
                i += 1;
                config.wait_timeout_secs = args
                    .get(i)
                    .ok_or("--timeout requires a value")?
                    .parse()
                    .map_err(|_| "--timeout must be a number")?;
            }
            "--restart" => {
                config.restart = true;
            }
            _ => {
                // Ignoruj nieznane argumenty
            }
        }
        i += 1;
    }

    // Walidacja
    if config.source_path.as_os_str().is_empty() {
        return Err("--source is required".into());
    }
    if config.target_path.as_os_str().is_empty() {
        return Err("--target is required".into());
    }
    if config.backup_path.as_os_str().is_empty() {
        return Err("--backup is required".into());
    }

    Ok(config)
}

fn main() {
    // Inicjalizacja tracing
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_env("LAUNCHER_HELPER_LOG")
                .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info")),
        )
        .init();

    let args: Vec<String> = std::env::args().skip(1).collect();

    if args.is_empty() || args.contains(&"--help".to_string()) {
        eprintln!("Usage: launcher-helper --source <path> --target <path> --backup <path> [--pid <PID>] [--sha256 <hash>] [--restart] [--timeout <secs>]");
        eprintln!();
        eprintln!("Self-update helper for SerwerCanary Launcher.");
        eprintln!("Replaces the launcher binary while it's not running.");
        std::process::exit(if args.is_empty() { 1 } else { 0 });
    }

    let config = match parse_args(&args) {
        Ok(c) => c,
        Err(e) => {
            tracing::error!("Invalid arguments: {}", e);
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    };

    match execute_self_update(&config) {
        Ok(()) => {
            tracing::info!("Self-update completed successfully");
            std::process::exit(0);
        }
        Err(e) => {
            tracing::error!("Self-update failed: {}", e);
            eprintln!("Self-update failed: {}", e);
            std::process::exit(2);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_args_minimal() {
        let args: Vec<String> = vec![
            "--source", "/tmp/new_launcher",
            "--target", "/opt/launcher/Launcher",
            "--backup", "/opt/launcher/Launcher.bak",
        ].into_iter().map(String::from).collect();

        let config = parse_args(&args).unwrap();
        assert_eq!(config.source_path, PathBuf::from("/tmp/new_launcher"));
        assert_eq!(config.target_path, PathBuf::from("/opt/launcher/Launcher"));
        assert_eq!(config.backup_path, PathBuf::from("/opt/launcher/Launcher.bak"));
        assert!(!config.restart);
        assert!(config.launcher_pid.is_none());
    }

    #[test]
    fn test_parse_args_full() {
        let args: Vec<String> = vec![
            "--pid", "12345",
            "--source", "/tmp/new",
            "--target", "/opt/launcher",
            "--backup", "/opt/launcher.bak",
            "--sha256", "abc123",
            "--restart",
            "--timeout", "60",
        ].into_iter().map(String::from).collect();

        let config = parse_args(&args).unwrap();
        assert_eq!(config.launcher_pid, Some(12345));
        assert!(config.restart);
        assert_eq!(config.expected_sha256, Some("abc123".into()));
        assert_eq!(config.wait_timeout_secs, 60);
    }

    #[test]
    fn test_parse_args_missing_source() {
        let args: Vec<String> = vec![
            "--target", "/opt/launcher",
            "--backup", "/opt/launcher.bak",
        ].into_iter().map(String::from).collect();

        assert!(parse_args(&args).is_err());
    }

    #[test]
    fn test_chrono_utc_now_format() {
        let ts = chrono_utc_now();
        // Format: YYYY-MM-DDTHH:MM:SSZ
        assert_eq!(ts.len(), 20);
        assert!(ts.ends_with('Z'));
        assert_eq!(&ts[4..5], "-");
        assert_eq!(&ts[7..8], "-");
        assert_eq!(&ts[10..11], "T");
    }

    #[test]
    fn test_sha256_file_bytes() {
        let tmp = tempfile::NamedTempFile::new().unwrap();
        std::fs::write(tmp.path(), b"test content").unwrap();
        let hash = sha256_file(tmp.path()).unwrap();
        // SHA-256 of "test content"
        assert_eq!(hash.len(), 64);
    }
}
