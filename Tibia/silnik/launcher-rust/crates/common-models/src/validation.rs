//! Walidacja — walidatory ogólnego przeznaczenia + re-eksport z manifest.rs.
//!
//! Moduł zawiera:
//! - walidację ścieżek (re-eksport z manifest)
//! - walidację URL
//! - walidację semver
//! - walidację nazw kanałów
//! - walidację SHA-256 hex stringów
//! - grace period (czy poprzednia wersja manifestu jest jeszcze akceptowana)

pub use crate::manifest::{validate_safe_rel_path, ManifestValidationError};

// ─────────────────────────────────────────────
// Walidacja URL
// ─────────────────────────────────────────────

/// Sprawdza czy URL jest poprawny (HTTPS wymagane w produkcji).
pub fn validate_url(url: &str, require_https: bool) -> Result<(), ValidationError> {
    let trimmed = url.trim();
    if trimmed.is_empty() {
        return Err(ValidationError::EmptyValue("url"));
    }

    // Musi zaczynać się od http:// lub https://
    if !trimmed.starts_with("http://") && !trimmed.starts_with("https://") {
        return Err(ValidationError::InvalidUrl {
            url: url.to_string(),
            reason: "must start with http:// or https://".to_string(),
        });
    }

    if require_https && !trimmed.starts_with("https://") {
        return Err(ValidationError::InvalidUrl {
            url: url.to_string(),
            reason: "HTTPS required in production".to_string(),
        });
    }

    // Sprawdź minimalną strukturę: scheme://host
    let after_scheme = if let Some(stripped) = trimmed.strip_prefix("https://") {
        stripped
    } else if let Some(stripped) = trimmed.strip_prefix("http://") {
        stripped
    } else {
        trimmed
    };

    if after_scheme.is_empty()
        || !after_scheme.contains('.') && !after_scheme.starts_with("localhost")
    {
        return Err(ValidationError::InvalidUrl {
            url: url.to_string(),
            reason: "missing host".to_string(),
        });
    }

    Ok(())
}

// ─────────────────────────────────────────────
// Walidacja semver
// ─────────────────────────────────────────────

/// Sprawdza czy string jest poprawną wersją semver (X.Y.Z).
pub fn validate_semver(version: &str) -> Result<(), ValidationError> {
    let trimmed = version.trim();
    if trimmed.is_empty() {
        return Err(ValidationError::EmptyValue("version"));
    }

    let parts: Vec<&str> = trimmed.split('.').collect();
    if parts.len() < 2 || parts.len() > 3 {
        return Err(ValidationError::InvalidSemver(version.to_string()));
    }

    for part in &parts {
        if part.parse::<u64>().is_err() {
            return Err(ValidationError::InvalidSemver(version.to_string()));
        }
    }

    Ok(())
}

// ─────────────────────────────────────────────
// Walidacja nazw kanałów
// ─────────────────────────────────────────────

/// Dozwolone kanały. Rozszerzalne w przyszłości.
const ALLOWED_CHANNELS: &[&str] = &["stable", "test", "dev", "canary", "beta"];

/// Sprawdza czy nazwa kanału jest dozwolona.
pub fn validate_channel(channel: &str) -> Result<(), ValidationError> {
    let trimmed = channel.trim().to_lowercase();
    if trimmed.is_empty() {
        return Err(ValidationError::EmptyValue("channel"));
    }

    if !ALLOWED_CHANNELS.contains(&trimmed.as_str()) {
        return Err(ValidationError::InvalidChannel {
            channel: channel.to_string(),
            allowed: ALLOWED_CHANNELS.iter().map(|s| s.to_string()).collect(),
        });
    }

    Ok(())
}

/// Zwraca listę dozwolonych kanałów.
pub fn allowed_channels() -> &'static [&'static str] {
    ALLOWED_CHANNELS
}

// ─────────────────────────────────────────────
// Walidacja SHA-256 hex
// ─────────────────────────────────────────────

/// Sprawdza czy string jest poprawnym SHA-256 hex (64 znaki, [0-9a-fA-F]).
pub fn validate_sha256_hex(hash: &str) -> Result<(), ValidationError> {
    if hash.len() != 64 {
        return Err(ValidationError::InvalidSha256 {
            value: hash.to_string(),
            reason: format!("expected 64 hex chars, got {}", hash.len()),
        });
    }

    if !hash.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(ValidationError::InvalidSha256 {
            value: hash.to_string(),
            reason: "contains non-hex characters".to_string(),
        });
    }

    Ok(())
}

// ─────────────────────────────────────────────
// Grace period — §5.4 spec: manifest version pinning
// ─────────────────────────────────────────────

/// Sprawdza czy grace period jest aktywny dla danego manifestu.
///
/// Jeśli manifest zawiera `gracePreviousVersionAcceptedUntilUtc`,
/// to API powinno akceptować filesHash obliczony zarówno z bieżącej,
/// jak i z poprzedniej wersji manifestu aż do podanej daty.
///
/// Zwraca `true` jeśli grace period jest aktywny (data nie minęła).
pub fn is_grace_period_active(grace_until_utc: Option<&str>, now_utc: &str) -> bool {
    match grace_until_utc {
        None => false,
        Some(until) => {
            // Porównanie leksykograficzne ISO 8601 dat (YYYY-MM-DDTHH:MM:SSZ)
            // Jest bezpieczne gdy oba stringi są w formacie ISO 8601.
            let until_trimmed = until.trim();
            let now_trimmed = now_utc.trim();

            if until_trimmed.is_empty() {
                return false;
            }

            // Jeśli now <= until → grace period aktywny
            now_trimmed <= until_trimmed
        }
    }
}

/// Decyduje czy dany filesHash jest akceptowalny w kontekście grace period.
///
/// - `current_expected` — oczekiwany hash z aktualnego manifestu
/// - `previous_expected` — oczekiwany hash z poprzedniego manifestu (opcjonalny)
/// - `actual_hash` — hash obliczony przez launchera
/// - `grace_active` — czy grace period jest aktywny
///
/// Zwraca `true` jeśli hash pasuje do current LUB (grace aktywny i pasuje do previous).
pub fn is_files_hash_acceptable(
    current_expected: &str,
    previous_expected: Option<&str>,
    actual_hash: &str,
    grace_active: bool,
) -> bool {
    // Porównanie case-insensitive
    if actual_hash.eq_ignore_ascii_case(current_expected) {
        return true;
    }

    if grace_active {
        if let Some(prev) = previous_expected {
            if actual_hash.eq_ignore_ascii_case(prev) {
                return true;
            }
        }
    }

    false
}

// ─────────────────────────────────────────────
// Błędy walidacji
// ─────────────────────────────────────────────

#[derive(Debug, thiserror::Error)]
pub enum ValidationError {
    #[error("Empty value for: {0}")]
    EmptyValue(&'static str),

    #[error("Invalid URL '{url}': {reason}")]
    InvalidUrl { url: String, reason: String },

    #[error("Invalid semver: {0}")]
    InvalidSemver(String),

    #[error("Invalid channel '{channel}', allowed: {allowed:?}")]
    InvalidChannel {
        channel: String,
        allowed: Vec<String>,
    },

    #[error("Invalid SHA-256 '{value}': {reason}")]
    InvalidSha256 { value: String, reason: String },
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    // --- URL ---

    #[test]
    fn test_valid_https_url() {
        assert!(validate_url("https://api.example.com/update.php", true).is_ok());
    }

    #[test]
    fn test_http_url_ok_when_not_required() {
        assert!(validate_url("http://localhost:8080/api", false).is_ok());
    }

    #[test]
    fn test_http_url_fails_when_https_required() {
        assert!(validate_url("http://api.example.com/", true).is_err());
    }

    #[test]
    fn test_empty_url_fails() {
        assert!(validate_url("", true).is_err());
    }

    #[test]
    fn test_ftp_url_fails() {
        assert!(validate_url("ftp://files.example.com/", false).is_err());
    }

    // --- Semver ---

    #[test]
    fn test_valid_semver() {
        assert!(validate_semver("1.0.0").is_ok());
        assert!(validate_semver("0.2.0").is_ok());
        assert!(validate_semver("12.34.56").is_ok());
    }

    #[test]
    fn test_two_part_semver_ok() {
        assert!(validate_semver("1.0").is_ok());
    }

    #[test]
    fn test_invalid_semver() {
        assert!(validate_semver("abc").is_err());
        assert!(validate_semver("1.0.0.0").is_err());
        assert!(validate_semver("").is_err());
    }

    // --- Channel ---

    #[test]
    fn test_valid_channels() {
        assert!(validate_channel("stable").is_ok());
        assert!(validate_channel("test").is_ok());
        assert!(validate_channel("dev").is_ok());
        assert!(validate_channel("canary").is_ok());
        assert!(validate_channel("beta").is_ok());
    }

    #[test]
    fn test_case_insensitive_channel() {
        assert!(validate_channel("STABLE").is_ok());
        assert!(validate_channel("Test").is_ok());
    }

    #[test]
    fn test_invalid_channel() {
        assert!(validate_channel("hacked").is_err());
        assert!(validate_channel("").is_err());
    }

    // --- SHA-256 ---

    #[test]
    fn test_valid_sha256() {
        let hash = "a".repeat(64);
        assert!(validate_sha256_hex(&hash).is_ok());
    }

    #[test]
    fn test_short_sha256_fails() {
        assert!(validate_sha256_hex("abc123").is_err());
    }

    #[test]
    fn test_non_hex_sha256_fails() {
        let hash = "g".repeat(64);
        assert!(validate_sha256_hex(&hash).is_err());
    }

    // --- Grace period ---

    #[test]
    fn test_grace_period_active() {
        assert!(is_grace_period_active(
            Some("2026-03-10T00:00:00Z"),
            "2026-03-03T12:00:00Z"
        ));
    }

    #[test]
    fn test_grace_period_expired() {
        assert!(!is_grace_period_active(
            Some("2026-03-01T00:00:00Z"),
            "2026-03-03T12:00:00Z"
        ));
    }

    #[test]
    fn test_grace_period_none() {
        assert!(!is_grace_period_active(None, "2026-03-03T12:00:00Z"));
    }

    #[test]
    fn test_grace_period_empty_string() {
        assert!(!is_grace_period_active(Some(""), "2026-03-03T12:00:00Z"));
    }

    // --- filesHash acceptable ---

    #[test]
    fn test_hash_matches_current() {
        assert!(is_files_hash_acceptable("abc123", None, "abc123", false));
    }

    #[test]
    fn test_hash_matches_previous_with_grace() {
        assert!(is_files_hash_acceptable(
            "new_hash",
            Some("old_hash"),
            "old_hash",
            true
        ));
    }

    #[test]
    fn test_hash_no_match_previous_without_grace() {
        assert!(!is_files_hash_acceptable(
            "new_hash",
            Some("old_hash"),
            "old_hash",
            false
        ));
    }

    #[test]
    fn test_hash_case_insensitive() {
        assert!(is_files_hash_acceptable("ABC123", None, "abc123", false));
    }

    #[test]
    fn test_hash_no_match() {
        assert!(!is_files_hash_acceptable("expected", None, "wrong", false));
    }
}
