//! LR-045: Weryfikacja pobranych artefaktów (instalatorów, paczek update).
//!
//! Waliduje:
//! - SHA-256 pobranego pliku vs oczekiwany hash
//! - Rozmiar pliku vs oczekiwany rozmiar
//! - (przyszłość) Podpis .sig

use crate::integrity::sha256_bytes;

/// Wynik weryfikacji artefaktu.
#[derive(Debug, Clone)]
pub struct ArtifactVerifyResult {
    pub filename: String,
    pub expected_sha256: String,
    pub actual_sha256: String,
    pub expected_size: Option<u64>,
    pub actual_size: u64,
    pub sha256_ok: bool,
    pub size_ok: bool,
}

impl ArtifactVerifyResult {
    pub fn is_ok(&self) -> bool {
        self.sha256_ok && self.size_ok
    }
}

/// Błędy weryfikacji artefaktu.
#[derive(Debug, thiserror::Error)]
pub enum ArtifactVerifyError {
    #[error("SHA-256 mismatch for '{filename}': expected {expected}, got {actual}")]
    HashMismatch {
        filename: String,
        expected: String,
        actual: String,
    },

    #[error("Size mismatch for '{filename}': expected {expected} bytes, got {actual} bytes")]
    SizeMismatch {
        filename: String,
        expected: u64,
        actual: u64,
    },

    #[error("Verification failed for '{filename}': {details}")]
    Failed { filename: String, details: String },
}

/// Weryfikuje pobrany artefakt (dane w pamięci) pod kątem SHA-256 i rozmiaru.
///
/// Zwraca `ArtifactVerifyResult` z wynikiem. Nie zwraca błędu — wynik zawiera
/// flagę `is_ok()`.
pub fn verify_artifact(
    data: &[u8],
    filename: &str,
    expected_sha256: &str,
    expected_size: Option<u64>,
) -> ArtifactVerifyResult {
    let actual_sha256 = sha256_bytes(data);
    let actual_size = data.len() as u64;

    let sha256_ok = actual_sha256.eq_ignore_ascii_case(expected_sha256);
    let size_ok = match expected_size {
        Some(expected) => actual_size == expected,
        None => true, // brak oczekiwanego rozmiaru = zawsze OK
    };

    ArtifactVerifyResult {
        filename: filename.to_string(),
        expected_sha256: expected_sha256.to_string(),
        actual_sha256,
        expected_size,
        actual_size,
        sha256_ok,
        size_ok,
    }
}

/// Weryfikuje artefakt i zwraca błąd jeśli hash lub rozmiar się nie zgadzają.
///
/// Wersja strict — przerywa operację na pierwszym mismatch.
pub fn verify_artifact_strict(
    data: &[u8],
    filename: &str,
    expected_sha256: &str,
    expected_size: Option<u64>,
) -> Result<ArtifactVerifyResult, ArtifactVerifyError> {
    let result = verify_artifact(data, filename, expected_sha256, expected_size);

    if !result.sha256_ok {
        return Err(ArtifactVerifyError::HashMismatch {
            filename: filename.to_string(),
            expected: expected_sha256.to_string(),
            actual: result.actual_sha256.clone(),
        });
    }

    if !result.size_ok {
        if let Some(expected) = expected_size {
            return Err(ArtifactVerifyError::SizeMismatch {
                filename: filename.to_string(),
                expected,
                actual: result.actual_size,
            });
        }
    }

    Ok(result)
}

/// Weryfikuje artefakt z dysku (plik).
pub fn verify_artifact_file(
    path: &std::path::Path,
    filename: &str,
    expected_sha256: &str,
    expected_size: Option<u64>,
) -> Result<ArtifactVerifyResult, ArtifactVerifyError> {
    let data = std::fs::read(path).map_err(|e| ArtifactVerifyError::Failed {
        filename: filename.to_string(),
        details: format!("Cannot read file: {}", e),
    })?;
    verify_artifact_strict(&data, filename, expected_sha256, expected_size)
}

// ─────────────────────────────────────────
// Testy
// ─────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_verify_artifact_ok() {
        let data = b"Hello, World!";
        let hash = sha256_bytes(data);
        let result = verify_artifact(data, "test.exe", &hash, Some(13));
        assert!(result.is_ok());
        assert!(result.sha256_ok);
        assert!(result.size_ok);
    }

    #[test]
    fn test_verify_artifact_hash_mismatch() {
        let data = b"Hello, World!";
        let result = verify_artifact(data, "test.exe", "badbadbadbadbad", Some(13));
        assert!(!result.is_ok());
        assert!(!result.sha256_ok);
        assert!(result.size_ok);
    }

    #[test]
    fn test_verify_artifact_size_mismatch() {
        let data = b"Hello, World!";
        let hash = sha256_bytes(data);
        let result = verify_artifact(data, "test.exe", &hash, Some(999));
        assert!(!result.is_ok());
        assert!(result.sha256_ok);
        assert!(!result.size_ok);
    }

    #[test]
    fn test_verify_artifact_no_expected_size() {
        let data = b"Hello, World!";
        let hash = sha256_bytes(data);
        let result = verify_artifact(data, "test.exe", &hash, None);
        assert!(result.is_ok());
    }

    #[test]
    fn test_verify_strict_hash_mismatch_returns_error() {
        let data = b"Hello, World!";
        let result = verify_artifact_strict(data, "test.exe", "wrong_hash", None);
        assert!(result.is_err());
        match result.unwrap_err() {
            ArtifactVerifyError::HashMismatch { filename, .. } => {
                assert_eq!(filename, "test.exe");
            }
            _ => panic!("Expected HashMismatch error"),
        }
    }

    #[test]
    fn test_verify_strict_size_mismatch_returns_error() {
        let data = b"Hello, World!";
        let hash = sha256_bytes(data);
        let result = verify_artifact_strict(data, "test.exe", &hash, Some(999));
        assert!(result.is_err());
        match result.unwrap_err() {
            ArtifactVerifyError::SizeMismatch { expected, actual, .. } => {
                assert_eq!(expected, 999);
                assert_eq!(actual, 13);
            }
            _ => panic!("Expected SizeMismatch error"),
        }
    }

    #[test]
    fn test_case_insensitive_hash_comparison() {
        let data = b"test data";
        let hash = sha256_bytes(data);
        // Uppercase hash should also match
        let result = verify_artifact(data, "test.bin", &hash.to_uppercase(), None);
        assert!(result.sha256_ok);
    }
}
