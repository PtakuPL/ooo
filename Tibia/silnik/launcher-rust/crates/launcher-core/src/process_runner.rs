//! LR-024: Process runner — uruchamia klienta gry z OTC_LAUNCH_TOKEN.
//!
//! Przekazuje token wyłącznie przez zmienną środowiskową (nie CLI),
//! zgodnie z planem bezpieczeństwa.

use std::path::Path;
use std::process::Command;

/// Błędy uruchamiania procesu.
#[derive(Debug, thiserror::Error)]
pub enum ProcessError {
    #[error("Client executable not found: {0}")]
    ClientNotFound(String),

    #[error("Failed to start client: {0}")]
    StartFailed(#[from] std::io::Error),

    #[error("Client exited with error code: {0}")]
    ExitError(i32),
}

/// Konfiguracja uruchamiania klienta.
#[derive(Debug, Clone)]
pub struct LaunchConfig {
    /// Ścieżka do pliku exe klienta.
    pub client_exe_path: String,
    /// Katalog roboczy klienta (zwykle katalog instalacji).
    pub working_dir: String,
    /// Launch token (UUID, jednorazowy, TTL 300s).
    pub launch_token: String,
    /// Kanał (stable/test/dev).
    pub channel: String,
    /// Dodatkowe zmienne środowiskowe.
    pub extra_env: Vec<(String, String)>,
}

/// Wynik uruchomienia klienta.
#[derive(Debug)]
pub struct LaunchResult {
    /// PID procesu klienta (jeśli uruchomiony w tle).
    pub pid: Option<u32>,
    /// Czy proces zakończył się od razu (jeśli czekaliśmy).
    pub exited: bool,
    /// Kod wyjścia (jeśli proces się zakończył).
    pub exit_code: Option<i32>,
}

fn scrub_client_environment(cmd: &mut Command) {
    for key in [
        "OTC_DEV_MODE",
        "OTC_GAME_MODE",
        "OTC_LAUNCH_TOKEN",
        "OTC_SESSION_TOKEN",
        "OTC_ACCOUNT",
        "OTC_CHARACTER_HINT",
        "OTC_CHANNEL",
    ] {
        cmd.env_remove(key);
    }
}

/// Uruchamia klienta gry z tokenem w zmiennej środowiskowej.
///
/// Klient dostaje:
/// - `OTC_LAUNCH_TOKEN` — jednorazowy token
/// - `OTC_CHANNEL` — kanał (stable/test/dev)
///
/// Launcher NIE czeka na zakończenie klienta — uruchamia go i oddaje kontrolę.
pub fn launch_client(config: &LaunchConfig) -> Result<LaunchResult, ProcessError> {
    let exe_path = Path::new(&config.client_exe_path);

    if !exe_path.exists() {
        return Err(ProcessError::ClientNotFound(config.client_exe_path.clone()));
    }

    tracing::info!(
        "Uruchamiam klienta: {} (channel={})",
        config.client_exe_path,
        config.channel
    );

    let mut cmd = Command::new(exe_path);
    cmd.current_dir(&config.working_dir);
    scrub_client_environment(&mut cmd);

    // Token WYŁĄCZNIE przez env — nigdy przez CLI arg
    cmd.env("OTC_LAUNCH_TOKEN", &config.launch_token);
    cmd.env("OTC_CHANNEL", &config.channel);

    // Dodatkowe zmienne środowiskowe
    for (key, value) in &config.extra_env {
        cmd.env(key, value);
    }

    let child = cmd.spawn()?;
    let pid = child.id();

    tracing::info!("Klient uruchomiony, PID: {}", pid);

    Ok(LaunchResult {
        pid: Some(pid),
        exited: false,
        exit_code: None,
    })
}

/// Uruchamia klienta i czeka na zakończenie (do testów/diagnostyki).
pub fn launch_client_and_wait(config: &LaunchConfig) -> Result<LaunchResult, ProcessError> {
    let exe_path = Path::new(&config.client_exe_path);

    if !exe_path.exists() {
        return Err(ProcessError::ClientNotFound(config.client_exe_path.clone()));
    }

    let mut cmd = Command::new(exe_path);
    cmd.current_dir(&config.working_dir);
    scrub_client_environment(&mut cmd);
    cmd.env("OTC_LAUNCH_TOKEN", &config.launch_token);
    cmd.env("OTC_CHANNEL", &config.channel);

    for (key, value) in &config.extra_env {
        cmd.env(key, value);
    }

    let output = cmd.output()?;
    let code = output.status.code().unwrap_or(-1);

    if code != 0 {
        tracing::warn!("Klient zakończył się z kodem: {}", code);
    }

    Ok(LaunchResult {
        pid: None,
        exited: true,
        exit_code: Some(code),
    })
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_client_not_found() {
        let config = LaunchConfig {
            client_exe_path: "/nonexistent/path/otclient.exe".to_string(),
            working_dir: "/tmp".to_string(),
            launch_token: "test-token".to_string(),
            channel: "test".to_string(),
            extra_env: Vec::new(),
        };
        let result = launch_client(&config);
        assert!(matches!(result, Err(ProcessError::ClientNotFound(_))));
    }

    #[cfg(target_os = "linux")]
    #[test]
    fn test_launch_simple_process() {
        // Na Linux możemy uruchomić /bin/true jako test
        let config = LaunchConfig {
            client_exe_path: "/bin/true".to_string(),
            working_dir: "/tmp".to_string(),
            launch_token: "test-token-uuid".to_string(),
            channel: "test".to_string(),
            extra_env: vec![("TEST_VAR".to_string(), "test_value".to_string())],
        };
        let result = launch_client_and_wait(&config).expect("launch");
        assert!(result.exited);
        assert_eq!(result.exit_code, Some(0));
    }
}
