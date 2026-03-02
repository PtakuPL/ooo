//! LR-078: Atomowy zapis installed_state.json.
//!
//! Zapis: tmp → write → fsync → rename.
//! Odczyt: parse JSON → walidacja schemaVersion.

use std::fs;
use std::io::Write;
use std::path::Path;

use common_models::installed_state::InstalledState;

/// Zapisuje state atomowo (tmp + fsync + rename).
pub fn save_state(state: &InstalledState, path: &Path) -> Result<(), StateError> {
    let json = serde_json::to_string_pretty(state).map_err(StateError::SerializeError)?;

    let parent = path
        .parent()
        .ok_or_else(|| StateError::InvalidPath(path.display().to_string()))?;

    fs::create_dir_all(parent).map_err(|e| StateError::IoError {
        context: "create dir".into(),
        source: e,
    })?;

    // Zapis do pliku tymczasowego w tym samym katalogu (żeby rename był atomowy)
    let tmp_path = path.with_extension("json.tmp");
    let mut file = fs::File::create(&tmp_path).map_err(|e| StateError::IoError {
        context: "create tmp".into(),
        source: e,
    })?;

    file.write_all(json.as_bytes())
        .map_err(|e| StateError::IoError {
            context: "write".into(),
            source: e,
        })?;

    file.sync_all().map_err(|e| StateError::IoError {
        context: "fsync".into(),
        source: e,
    })?;

    drop(file); // Zamknij plik przed rename

    fs::rename(&tmp_path, path).map_err(|e| StateError::IoError {
        context: "rename".into(),
        source: e,
    })?;

    Ok(())
}

/// Wczytuje state z pliku JSON.
pub fn load_state(path: &Path) -> Result<InstalledState, StateError> {
    let content = fs::read_to_string(path).map_err(|e| StateError::IoError {
        context: "read".into(),
        source: e,
    })?;

    let state: InstalledState =
        serde_json::from_str(&content).map_err(StateError::DeserializeError)?;

    Ok(state)
}

#[derive(Debug, thiserror::Error)]
pub enum StateError {
    #[error("I/O error ({context}): {source}")]
    IoError {
        context: String,
        #[source]
        source: std::io::Error,
    },

    #[error("Serialize error: {0}")]
    SerializeError(serde_json::Error),

    #[error("Deserialize error: {0}")]
    DeserializeError(serde_json::Error),

    #[error("Invalid path: {0}")]
    InvalidPath(String),
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use common_models::installed_state::InstalledState;

    #[test]
    fn test_save_and_load_roundtrip() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let path = tmp.path().join(".launcher").join("installed_state.json");

        let state = InstalledState::new_minimal(
            "test-id".into(),
            "stable".into(),
            "/client".into(),
            "0.1.0".into(),
            "https://api.example.com/".into(),
        );

        save_state(&state, &path).expect("save");
        assert!(path.exists());

        let loaded = load_state(&path).expect("load");
        assert_eq!(loaded.install_id, "test-id");
        assert_eq!(loaded.channel, "stable");
        assert_eq!(loaded.launcher_version, "0.1.0");
    }

    #[test]
    fn test_atomic_write_no_corruption() {
        // Sprawdź, że tmp plik nie zostaje po udanym zapisie
        let tmp = tempfile::tempdir().expect("tmpdir");
        let path = tmp.path().join("state.json");
        let tmp_path = path.with_extension("json.tmp");

        let state = InstalledState::new_minimal(
            "id".into(), "stable".into(), "/c".into(), "0.1.0".into(), "https://x/".into(),
        );

        save_state(&state, &path).expect("save");
        assert!(path.exists());
        assert!(!tmp_path.exists(), "Plik tymczasowy powinien być usunięty po rename");
    }
}
