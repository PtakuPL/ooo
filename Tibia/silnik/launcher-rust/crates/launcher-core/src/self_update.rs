//! LR-048..051: Self-update launchera.
//!
//! Moduł koordynuje cały flow self-update:
//! 1. Sprawdzenie wersji (launcher-version.php) — LR-048
//! 2. Pobranie nowej paczki + weryfikacja SHA-256 — LR-049
//! 3. Uruchomienie helpera i restart — LR-050
//! 4. Scenariusz rollback — LR-051
//!
//! Launcher NIE może nadpisać sam siebie w trakcie działania.
//! Dlatego pobiera nową binarkę do staging/ i deleguje podmianę do launcher-helper.

use std::path::{Path, PathBuf};

use common_models::api_responses::LauncherVersionResponse;

// ─────────────────────────────────────────────
// Typy i struktury
// ─────────────────────────────────────────────

/// Wynik sprawdzenia wersji launchera (LR-048).
#[derive(Debug, Clone)]
pub enum VersionCheckResult {
    /// Launcher jest aktualny.
    UpToDate,
    /// Dostępna jest nowa wersja (soft update — propozycja).
    UpdateAvailable {
        current: String,
        latest: String,
        url: String,
        sha256: Option<String>,
        notes: Option<String>,
    },
    /// Wymagana jest aktualizacja (hard block — launcher nie pozwala kontynuować).
    UpdateRequired {
        current: String,
        latest: String,
        min_version: String,
        url: String,
        sha256: Option<String>,
        notes: Option<String>,
    },
}

/// Status self-update procesu.
#[derive(Debug, Clone, serde::Serialize)]
#[serde(rename_all = "camelCase")]
pub enum SelfUpdateStatus {
    Idle,
    Checking,
    Downloading,
    Verifying,
    PreparingHelper,
    WaitingForRestart,
    Failed { error: String },
}

/// Parametry do przygotowania self-update.
#[derive(Debug, Clone)]
pub struct SelfUpdatePlan {
    /// URL do pobrania nowej binarki.
    pub download_url: String,
    /// Oczekiwany SHA-256 nowej binarki.
    pub expected_sha256: String,
    /// Ścieżka staging (gdzie pobieramy nową binarkę).
    pub staging_path: PathBuf,
    /// Ścieżka docelowa launchera (do podmiany).
    pub target_path: PathBuf,
    /// Ścieżka backup starego launchera.
    pub backup_path: PathBuf,
    /// Ścieżka helpera.
    pub helper_path: PathBuf,
    /// Czy restart po update.
    pub restart: bool,
}

/// Błędy self-update.
#[derive(Debug, thiserror::Error)]
pub enum SelfUpdateError {
    #[error("Version check failed: {0}")]
    VersionCheckFailed(String),

    #[error("Download failed: {0}")]
    DownloadFailed(String),

    #[error("Hash mismatch: expected {expected}, got {actual}")]
    HashMismatch { expected: String, actual: String },

    #[error("Helper not found at {0}")]
    HelperNotFound(PathBuf),

    #[error("Failed to launch helper: {0}")]
    HelperLaunchFailed(String),

    #[error("Rollback needed: {reason}")]
    RollbackNeeded { reason: String },

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
}

// ─────────────────────────────────────────────
// LR-048: Sprawdzenie wersji
// ─────────────────────────────────────────────

/// Porównuje lokalne wersje launchera z odpowiedzią z API.
///
/// Logika:
/// 1. Jeśli lokalna < minVersion → UpdateRequired (hard block)
/// 2. Jeśli lokalna < version i required=true → UpdateRequired
/// 3. Jeśli lokalna < version i required=false → UpdateAvailable (soft)
/// 4. Jeśli lokalna >= version → UpToDate
pub fn check_launcher_version(
    current_version: &str,
    server_response: &LauncherVersionResponse,
) -> VersionCheckResult {
    let current = match semver::Version::parse(current_version) {
        Ok(v) => v,
        Err(_) => {
            tracing::warn!("Cannot parse current launcher version: {}", current_version);
            // Nie można porównać → traktujemy jako nieaktualny
            return VersionCheckResult::UpdateRequired {
                current: current_version.to_string(),
                latest: server_response.version.clone(),
                min_version: server_response.min_version.clone(),
                url: server_response.url.clone(),
                sha256: server_response.sha256.clone(),
                notes: server_response.notes.clone(),
            };
        }
    };

    let latest = match semver::Version::parse(&server_response.version) {
        Ok(v) => v,
        Err(_) => {
            tracing::warn!(
                "Cannot parse server launcher version: {}",
                server_response.version
            );
            return VersionCheckResult::UpToDate; // Nie blokujemy jeśli serwer zwraca śmieci
        }
    };

    let min = match semver::Version::parse(&server_response.min_version) {
        Ok(v) => v,
        Err(_) => {
            tracing::warn!("Cannot parse minVersion: {}", server_response.min_version);
            semver::Version::new(0, 0, 0) // Brak min = nie blokujemy
        }
    };

    // Check 1: current < minVersion → hard block
    if current < min {
        return VersionCheckResult::UpdateRequired {
            current: current_version.to_string(),
            latest: server_response.version.clone(),
            min_version: server_response.min_version.clone(),
            url: server_response.url.clone(),
            sha256: server_response.sha256.clone(),
            notes: server_response.notes.clone(),
        };
    }

    // Check 2: current < latest
    if current < latest {
        if server_response.required {
            return VersionCheckResult::UpdateRequired {
                current: current_version.to_string(),
                latest: server_response.version.clone(),
                min_version: server_response.min_version.clone(),
                url: server_response.url.clone(),
                sha256: server_response.sha256.clone(),
                notes: server_response.notes.clone(),
            };
        } else {
            return VersionCheckResult::UpdateAvailable {
                current: current_version.to_string(),
                latest: server_response.version.clone(),
                url: server_response.url.clone(),
                sha256: server_response.sha256.clone(),
                notes: server_response.notes.clone(),
            };
        }
    }

    // Check 3: up to date
    VersionCheckResult::UpToDate
}

// ─────────────────────────────────────────────
// LR-049: Pobranie paczki + weryfikacja
// ─────────────────────────────────────────────

/// Weryfikuje pobraną paczkę self-update.
/// Zwraca Err jeśli hash się nie zgadza.
pub fn verify_self_update_package(
    data: &[u8],
    expected_sha256: &str,
) -> Result<(), SelfUpdateError> {
    use crate::integrity::sha256_bytes;

    let actual = sha256_bytes(data);
    if actual.eq_ignore_ascii_case(expected_sha256) {
        tracing::info!("Self-update package SHA-256 verified OK");
        Ok(())
    } else {
        Err(SelfUpdateError::HashMismatch {
            expected: expected_sha256.to_string(),
            actual,
        })
    }
}

/// Zapisuje pobraną paczkę do staging.
pub fn stage_self_update_package(data: &[u8], staging_path: &Path) -> Result<(), SelfUpdateError> {
    if let Some(parent) = staging_path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(staging_path, data)?;
    tracing::info!("Self-update package staged: {}", staging_path.display());
    Ok(())
}

// ─────────────────────────────────────────────
// LR-050: Uruchomienie helpera i restart
// ─────────────────────────────────────────────

/// Przygotowuje i uruchamia launcher-helper do podmiany binarki.
///
/// Flow:
/// 1. Sprawdza czy helper istnieje pod helper_path
/// 2. Uruchamia helper z parametrami CLI
/// 3. Launcher powinien się zamknąć (caller odpowiada za exit)
///
/// WAŻNE: Po wywołaniu tej funkcji launcher MUSI się zamknąć,
/// żeby helper mógł podmienić binarkę.
pub fn launch_helper(plan: &SelfUpdatePlan) -> Result<u32, SelfUpdateError> {
    if !plan.helper_path.exists() {
        return Err(SelfUpdateError::HelperNotFound(plan.helper_path.clone()));
    }

    let current_pid = std::process::id();

    let mut cmd = std::process::Command::new(&plan.helper_path);
    cmd.arg("--pid")
        .arg(current_pid.to_string())
        .arg("--source")
        .arg(&plan.staging_path)
        .arg("--target")
        .arg(&plan.target_path)
        .arg("--backup")
        .arg(&plan.backup_path)
        .arg("--sha256")
        .arg(&plan.expected_sha256);

    if plan.restart {
        cmd.arg("--restart");
    }

    tracing::info!(
        "Launching helper: {} --pid {} --source {} --target {} --backup {}",
        plan.helper_path.display(),
        current_pid,
        plan.staging_path.display(),
        plan.target_path.display(),
        plan.backup_path.display(),
    );

    let child = cmd.spawn().map_err(|e| {
        SelfUpdateError::HelperLaunchFailed(format!(
            "Cannot start helper {}: {}",
            plan.helper_path.display(),
            e
        ))
    })?;

    let helper_pid = child.id();
    tracing::info!("Helper started with PID: {}", helper_pid);

    Ok(helper_pid)
}

// ─────────────────────────────────────────────
// LR-051: Rollback
// ─────────────────────────────────────────────

/// Sprawdza czy jest potrzebny rollback po nieudanym self-update.
///
/// Launcher przy starcie może sprawdzić:
/// 1. Czy istnieje plik `*.update_status.json` z wynikiem helpera
/// 2. Jeśli wynik = failed, przywraca backup
pub fn check_for_rollback(
    backup_path: &Path,
    _target_path: &Path,
) -> Result<bool, SelfUpdateError> {
    let status_path = backup_path.with_extension("update_status.json");

    if !status_path.exists() {
        return Ok(false); // Brak statusu = brak rollbacku
    }

    let content = std::fs::read_to_string(&status_path)?;
    let status: serde_json::Value = serde_json::from_str(&content).unwrap_or_default();

    if status.get("result").and_then(|v| v.as_str()) == Some("success") {
        // Update się powiódł — wyczyść pliki
        let _ = std::fs::remove_file(&status_path);
        let _ = std::fs::remove_file(backup_path);
        tracing::info!("Previous self-update was successful, cleaning up");
        return Ok(false);
    }

    // Update się nie powiódł — sprawdź czy backup istnieje
    if backup_path.exists() {
        tracing::warn!(
            "Previous self-update may have failed — backup exists at {}",
            backup_path.display()
        );
        // NIE robimy automatycznego rollbacku — zostawiamy decyzję launcherowi
        return Ok(true);
    }

    Ok(false)
}

/// Wykonuje rollback: przywraca backup do target.
pub fn perform_rollback(backup_path: &Path, target_path: &Path) -> Result<(), SelfUpdateError> {
    if !backup_path.exists() {
        return Err(SelfUpdateError::RollbackNeeded {
            reason: format!("Backup not found at {}", backup_path.display()),
        });
    }

    std::fs::copy(backup_path, target_path)?;
    tracing::info!(
        "Rollback complete: {} -> {}",
        backup_path.display(),
        target_path.display()
    );

    // Cleanup
    let _ = std::fs::remove_file(backup_path);
    let status_path = backup_path.with_extension("update_status.json");
    let _ = std::fs::remove_file(&status_path);

    Ok(())
}

/// Buduje SelfUpdatePlan na podstawie odpowiedzi wersji i ścieżek.
pub fn build_self_update_plan(
    download_url: &str,
    expected_sha256: &str,
    launcher_data_dir: &Path,
    launcher_exe_path: &Path,
) -> SelfUpdatePlan {
    let staging_dir = launcher_data_dir.join("staging");
    let backup_dir = launcher_data_dir.join("backups");

    // Nazwa helpera platformowo-zależna
    let helper_name = if cfg!(windows) {
        "LauncherHelper.exe"
    } else {
        "launcher-helper"
    };

    // Helper leży obok launchera
    let helper_path = launcher_exe_path
        .parent()
        .unwrap_or(Path::new("."))
        .join(helper_name);

    SelfUpdatePlan {
        download_url: download_url.to_string(),
        expected_sha256: expected_sha256.to_string(),
        staging_path: staging_dir.join("launcher_update_package"),
        target_path: launcher_exe_path.to_path_buf(),
        backup_path: backup_dir.join("launcher_previous"),
        helper_path,
        restart: true,
    }
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use common_models::api_responses::LauncherVersionResponse;

    fn make_version_response(
        version: &str,
        min_version: &str,
        required: bool,
    ) -> LauncherVersionResponse {
        LauncherVersionResponse {
            version: version.to_string(),
            min_version: min_version.to_string(),
            required,
            url: "https://cdn.example.com/launcher.tar.gz".to_string(),
            sha256: Some("abc123".to_string()),
            release_date: None,
            notes: None,
        }
    }

    #[test]
    fn test_up_to_date() {
        let resp = make_version_response("0.1.0", "0.1.0", false);
        match check_launcher_version("0.1.0", &resp) {
            VersionCheckResult::UpToDate => {}
            other => panic!("Expected UpToDate, got {:?}", other),
        }
    }

    #[test]
    fn test_newer_version_available() {
        let resp = make_version_response("0.2.0", "0.1.0", false);
        match check_launcher_version("0.1.0", &resp) {
            VersionCheckResult::UpdateAvailable {
                current, latest, ..
            } => {
                assert_eq!(current, "0.1.0");
                assert_eq!(latest, "0.2.0");
            }
            other => panic!("Expected UpdateAvailable, got {:?}", other),
        }
    }

    #[test]
    fn test_required_update() {
        let resp = make_version_response("0.2.0", "0.1.0", true);
        match check_launcher_version("0.1.0", &resp) {
            VersionCheckResult::UpdateRequired { .. } => {}
            other => panic!("Expected UpdateRequired, got {:?}", other),
        }
    }

    #[test]
    fn test_below_min_version() {
        let resp = make_version_response("0.3.0", "0.2.0", false);
        match check_launcher_version("0.1.0", &resp) {
            VersionCheckResult::UpdateRequired { min_version, .. } => {
                assert_eq!(min_version, "0.2.0");
            }
            other => panic!("Expected UpdateRequired (below min), got {:?}", other),
        }
    }

    #[test]
    fn test_newer_than_server() {
        let resp = make_version_response("0.1.0", "0.1.0", false);
        match check_launcher_version("0.2.0", &resp) {
            VersionCheckResult::UpToDate => {}
            other => panic!("Expected UpToDate (newer than server), got {:?}", other),
        }
    }

    #[test]
    fn test_verify_package_ok() {
        use crate::integrity::sha256_bytes;
        let data = b"test self-update package";
        let hash = sha256_bytes(data);
        assert!(verify_self_update_package(data, &hash).is_ok());
    }

    #[test]
    fn test_verify_package_mismatch() {
        let data = b"test self-update package";
        let result = verify_self_update_package(data, "wrong_hash");
        assert!(result.is_err());
    }

    #[test]
    fn test_build_self_update_plan() {
        let plan = build_self_update_plan(
            "https://cdn.example.com/launcher.tar.gz",
            "abc123",
            Path::new("/opt/launcher/data"),
            Path::new("/opt/launcher/Launcher"),
        );
        assert_eq!(plan.download_url, "https://cdn.example.com/launcher.tar.gz");
        assert_eq!(plan.expected_sha256, "abc123");
        assert!(plan.staging_path.to_str().unwrap().contains("staging"));
        assert!(plan.backup_path.to_str().unwrap().contains("backups"));
        assert!(plan.restart);
    }

    #[test]
    fn test_stage_and_verify_roundtrip() {
        use crate::integrity::sha256_bytes;

        let tmp = tempfile::tempdir().unwrap();
        let data = b"new launcher binary content";
        let hash = sha256_bytes(data);

        let staging = tmp.path().join("staging").join("launcher_new");
        stage_self_update_package(data, &staging).unwrap();

        // Verify the staged file
        let read_data = std::fs::read(&staging).unwrap();
        assert!(verify_self_update_package(&read_data, &hash).is_ok());
    }
}
