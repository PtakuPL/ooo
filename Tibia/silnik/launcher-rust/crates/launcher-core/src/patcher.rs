//! LR-019/020/021/022: Patcher — pobieranie, weryfikacja, staging, atomowa podmiana, rollback.
//!
//! Flow patchera:
//! 1. Utwórz katalog staging
//! 2. Pobierz pliki do staging
//! 3. Zweryfikuj SHA-256 każdego pobranego pliku
//! 4. Wykonaj backup istniejących plików
//! 5. Atomowa podmiana: staging → docelowy
//! 6. Usuń pliki z manifestu (action=delete)
//! 7. Przy błędzie: rollback z backupu

use std::fs;
use std::path::{Path, PathBuf};

use common_models::installed_state::{InstalledState, ManagedFileState, UpdateTxStatus};
use common_models::update_plan::UpdatePlan;

use crate::integrity::sha256_bytes;
use crate::state;

/// Błędy patchera.
#[derive(Debug, thiserror::Error)]
pub enum PatcherError {
    #[error("I/O error ({context}): {source}")]
    IoError {
        context: String,
        #[source]
        source: std::io::Error,
    },

    #[error("Hash mismatch for '{path}': expected {expected}, got {actual}")]
    HashMismatch {
        path: String,
        expected: String,
        actual: String,
    },

    #[error("Download failed for '{path}': {message}")]
    DownloadFailed { path: String, message: String },

    #[error("Rollback error: {0}")]
    RollbackError(String),

    #[error("State error: {0}")]
    StateError(#[from] state::StateError),
}

/// Kontekst patchowania — przechowuje ścieżki i stan.
pub struct PatchContext {
    /// Katalog klienta (gdzie instalowane są pliki).
    pub client_dir: PathBuf,
    /// Katalog staging (tmp pliki przed podmianą).
    pub staging_dir: PathBuf,
    /// Katalog backup (kopie zapasowe przed podmianą).
    pub backup_dir: PathBuf,
    /// Ścieżka do installed_state.json.
    pub state_path: PathBuf,
}

impl PatchContext {
    /// Tworzy nowy kontekst patchowania z unikalnym ID transakcji.
    pub fn new(client_dir: &Path, launcher_data_dir: &Path, tx_id: &str) -> Self {
        let staging_dir = launcher_data_dir.join("staging").join(tx_id);
        let backup_dir = launcher_data_dir.join("backup").join(tx_id);
        let state_path = launcher_data_dir.join("installed_state.json");

        Self {
            client_dir: client_dir.to_path_buf(),
            staging_dir,
            backup_dir,
            state_path,
        }
    }

    /// Inicjalizuje katalogi staging i backup.
    pub fn init_dirs(&self) -> Result<(), PatcherError> {
        fs::create_dir_all(&self.staging_dir).map_err(|e| PatcherError::IoError {
            context: "create staging dir".into(),
            source: e,
        })?;

        fs::create_dir_all(&self.backup_dir).map_err(|e| PatcherError::IoError {
            context: "create backup dir".into(),
            source: e,
        })?;

        Ok(())
    }

    /// Sprząta katalogi staging i backup po udanym update.
    pub fn cleanup(&self) -> Result<(), PatcherError> {
        if self.staging_dir.exists() {
            fs::remove_dir_all(&self.staging_dir).map_err(|e| PatcherError::IoError {
                context: "cleanup staging".into(),
                source: e,
            })?;
        }
        if self.backup_dir.exists() {
            fs::remove_dir_all(&self.backup_dir).map_err(|e| PatcherError::IoError {
                context: "cleanup backup".into(),
                source: e,
            })?;
        }
        Ok(())
    }
}

/// LR-020: Weryfikuje pobrany plik po SHA-256.
///
/// Zwraca Ok(()) jeśli hash się zgadza, Err jeśli nie.
pub fn verify_downloaded_file(
    data: &[u8],
    expected_sha256: &str,
    path: &str,
) -> Result<(), PatcherError> {
    let actual = sha256_bytes(data);
    if actual != expected_sha256 {
        return Err(PatcherError::HashMismatch {
            path: path.to_string(),
            expected: expected_sha256.to_string(),
            actual,
        });
    }
    Ok(())
}

/// LR-019+020: Zapisuje pobrany plik do staging po weryfikacji hash.
pub fn stage_file(
    ctx: &PatchContext,
    path: &str,
    data: &[u8],
    expected_sha256: &str,
) -> Result<(), PatcherError> {
    // Weryfikuj hash
    verify_downloaded_file(data, expected_sha256, path)?;

    // Zapisz do staging
    let staged_path = ctx.staging_dir.join(path);
    if let Some(parent) = staged_path.parent() {
        fs::create_dir_all(parent).map_err(|e| PatcherError::IoError {
            context: format!("create staging subdir for {}", path),
            source: e,
        })?;
    }

    fs::write(&staged_path, data).map_err(|e| PatcherError::IoError {
        context: format!("write staged file {}", path),
        source: e,
    })?;

    tracing::debug!("Staged: {} ({} bytes, hash OK)", path, data.len());
    Ok(())
}

/// LR-021: Tworzy backup istniejącego pliku przed podmianą.
pub fn backup_file(ctx: &PatchContext, path: &str) -> Result<(), PatcherError> {
    let source = ctx.client_dir.join(path);
    if !source.exists() {
        return Ok(()); // Nowy plik — nie ma czego backupować
    }

    let backup_path = ctx.backup_dir.join(path);
    if let Some(parent) = backup_path.parent() {
        fs::create_dir_all(parent).map_err(|e| PatcherError::IoError {
            context: format!("create backup dir for {}", path),
            source: e,
        })?;
    }

    fs::copy(&source, &backup_path).map_err(|e| PatcherError::IoError {
        context: format!("backup {}", path),
        source: e,
    })?;

    tracing::debug!("Backup: {}", path);
    Ok(())
}

/// LR-021: Atomowa podmiana pliku ze staging do docelowego katalogu.
pub fn apply_staged_file(ctx: &PatchContext, path: &str) -> Result<(), PatcherError> {
    let staged = ctx.staging_dir.join(path);
    let target = ctx.client_dir.join(path);

    if let Some(parent) = target.parent() {
        fs::create_dir_all(parent).map_err(|e| PatcherError::IoError {
            context: format!("create target dir for {}", path),
            source: e,
        })?;
    }

    fs::rename(&staged, &target)
        .or_else(|_| {
            // Fallback: rename może nie działać cross-device → kopiuj + usuń
            fs::copy(&staged, &target)
                .and_then(|_| fs::remove_file(&staged))
                .map(|_| ())
        })
        .map_err(|e| PatcherError::IoError {
            context: format!("apply staged file {}", path),
            source: e,
        })?;

    tracing::debug!("Applied: {}", path);
    Ok(())
}

/// Aplikuje cały plan: backup → apply staged → delete files.
///
/// `staged_files` — lista ścieżek plików już pobranych i zstaginowanych.
pub fn apply_plan(
    ctx: &PatchContext,
    plan: &UpdatePlan,
    staged_files: &[String],
    state: &mut InstalledState,
) -> Result<(), PatcherError> {
    // Faza 1: Backup istniejących plików
    state.update_transaction.status = UpdateTxStatus::Applying;
    state::save_state(state, &ctx.state_path)?;

    for path in staged_files {
        backup_file(ctx, path)?;
        state.update_transaction.backup_files.push(path.clone());
    }

    // Faza 2: Podmiana plików ze staging
    for path in staged_files {
        apply_staged_file(ctx, path)?;
        state.update_transaction.updated_files.push(path.clone());
    }

    // Faza 3: Usuwanie plików
    for del in &plan.to_delete {
        let target = ctx.client_dir.join(&del.path);
        if target.exists() {
            // Backup przed usunięciem
            backup_file(ctx, &del.path)?;
            fs::remove_file(&target).map_err(|e| PatcherError::IoError {
                context: format!("delete {}", del.path),
                source: e,
            })?;
            state
                .update_transaction
                .delete_applied
                .push(del.path.clone());
            tracing::debug!("Deleted: {}", del.path);
        }
    }

    Ok(())
}

/// LR-022: Rollback — przywraca pliki z backupu po błędzie.
pub fn rollback(ctx: &PatchContext, state: &mut InstalledState) -> Result<(), PatcherError> {
    tracing::warn!(
        "Uruchamiam rollback transakcji: {}",
        state.update_transaction.tx_id
    );
    state.update_transaction.status = UpdateTxStatus::RollbackInProgress;
    state::save_state(state, &ctx.state_path)?;

    let mut errors: Vec<String> = Vec::new();

    // Przywróć podmienione pliki z backupu
    for path in &state.update_transaction.updated_files {
        let backup = ctx.backup_dir.join(path);
        let target = ctx.client_dir.join(path);

        if backup.exists() {
            if let Err(e) = fs::copy(&backup, &target) {
                errors.push(format!("Nie mogę przywrócić {}: {}", path, e));
            } else {
                tracing::info!("Rollback: przywrócono {}", path);
            }
        }
    }

    // Przywróć usunięte pliki z backupu
    for path in &state.update_transaction.delete_applied {
        let backup = ctx.backup_dir.join(path);
        let target = ctx.client_dir.join(path);

        if backup.exists() {
            if let Err(e) = fs::copy(&backup, &target) {
                errors.push(format!("Nie mogę odtworzyć {}: {}", path, e));
            } else {
                tracing::info!("Rollback: odtworzono usunięty {}", path);
            }
        }
    }

    if errors.is_empty() {
        state.update_transaction.mark_idle();
        state::save_state(state, &ctx.state_path)?;
        tracing::info!("Rollback zakończony pomyślnie");
        Ok(())
    } else {
        let msg = errors.join("; ");
        Err(PatcherError::RollbackError(msg))
    }
}

/// LR-022: Sprawdza czy potrzebna jest recovery przy starcie launchera.
/// Jeśli updateTransaction.status != idle → powinniśmy zrobić rollback.
pub fn check_recovery_needed(state: &InstalledState) -> bool {
    state.update_transaction.needs_recovery()
}

/// Aktualizuje managed_files_index po udanym update.
pub fn update_managed_index(state: &mut InstalledState, plan: &UpdatePlan, now_utc: &str) {
    // Dodaj/zaktualizuj pliki pobrane
    for file in &plan.to_replace {
        state.managed_files_index.insert(
            file.path.clone(),
            ManagedFileState {
                sha256: file.expected_sha256.clone(),
                size: file.size,
                manifest_version: plan.target_manifest_version.clone(),
                managed: true,
                installed_at_utc: now_utc.to_string(),
                tags: Vec::new(),
                was_modified_locally: false,
            },
        );
    }

    // Usuń wpisy dla skasowanych plików
    for del in &plan.to_delete {
        state.managed_files_index.remove(&del.path);
    }
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use crate::integrity::sha256_bytes;

    #[test]
    fn test_verify_downloaded_file_ok() {
        let data = b"hello world";
        let expected = sha256_bytes(data);
        assert!(verify_downloaded_file(data, &expected, "test.txt").is_ok());
    }

    #[test]
    fn test_verify_downloaded_file_mismatch() {
        let data = b"hello world";
        let result = verify_downloaded_file(data, "wrong_hash", "test.txt");
        assert!(matches!(result, Err(PatcherError::HashMismatch { .. })));
    }

    #[test]
    fn test_stage_and_apply() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let client_dir = tmp.path().join("client");
        let launcher_dir = tmp.path().join(".launcher");
        fs::create_dir_all(&client_dir).expect("mkdir");

        let ctx = PatchContext::new(&client_dir, &launcher_dir, "test-tx-1");
        ctx.init_dirs().expect("init dirs");

        // Przygotuj dane
        let data = b"new file content";
        let expected_sha = sha256_bytes(data);

        // Stage pliku
        stage_file(&ctx, "modules/test.lua", data, &expected_sha).expect("stage");
        assert!(ctx.staging_dir.join("modules/test.lua").exists());

        // Apply
        apply_staged_file(&ctx, "modules/test.lua").expect("apply");
        assert!(client_dir.join("modules/test.lua").exists());

        let content = fs::read_to_string(client_dir.join("modules/test.lua")).expect("read");
        assert_eq!(content, "new file content");
    }

    #[test]
    fn test_backup_and_rollback() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let client_dir = tmp.path().join("client");
        let launcher_dir = tmp.path().join(".launcher");
        fs::create_dir_all(&client_dir).expect("mkdir");

        let ctx = PatchContext::new(&client_dir, &launcher_dir, "test-tx-2");
        ctx.init_dirs().expect("init dirs");

        // Utwórz oryginalny plik
        fs::write(client_dir.join("original.txt"), b"original").expect("write");

        // Backup
        backup_file(&ctx, "original.txt").expect("backup");
        assert!(ctx.backup_dir.join("original.txt").exists());

        // Nadpisz plik
        fs::write(client_dir.join("original.txt"), b"modified").expect("write");

        // Przygotuj state do rollback
        let mut installed = InstalledState::new_minimal(
            "test".into(),
            "stable".into(),
            client_dir.to_string_lossy().to_string(),
            "0.1.0".into(),
            "https://api/".into(),
        );
        installed.update_transaction.tx_id = "test-tx-2".into();
        installed.update_transaction.status = UpdateTxStatus::Applying;
        installed
            .update_transaction
            .updated_files
            .push("original.txt".into());

        // Zapisz state (rollback go potrzebuje)
        state::save_state(&installed, &ctx.state_path).expect("save state");

        // Rollback
        rollback(&ctx, &mut installed).expect("rollback");

        // Plik powinien wrócić do oryginału
        let content = fs::read_to_string(client_dir.join("original.txt")).expect("read");
        assert_eq!(content, "original");
    }

    #[test]
    fn test_cleanup() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let launcher_dir = tmp.path().join(".launcher");

        let ctx = PatchContext::new(tmp.path(), &launcher_dir, "test-tx-3");
        ctx.init_dirs().expect("init dirs");

        assert!(ctx.staging_dir.exists());
        assert!(ctx.backup_dir.exists());

        ctx.cleanup().expect("cleanup");
        assert!(!ctx.staging_dir.exists());
        assert!(!ctx.backup_dir.exists());
    }

    #[test]
    fn test_check_recovery_needed() {
        let state = InstalledState::new_minimal(
            "test".into(),
            "stable".into(),
            "/c".into(),
            "0.1.0".into(),
            "https://api/".into(),
        );
        assert!(!check_recovery_needed(&state));

        let mut state2 = state;
        state2.update_transaction.status = UpdateTxStatus::Downloading;
        assert!(check_recovery_needed(&state2));
    }
}
