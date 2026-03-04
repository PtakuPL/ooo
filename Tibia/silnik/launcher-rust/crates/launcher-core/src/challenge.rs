//! LR-052: Challenge-response flow for launch-token hardening.
//!
//! Flow:
//! 1. Launcher calls GET /challenge.php → receives nonce + TTL.
//! 2. Launcher computes: SHA-256(nonce + ":" + filesHash) = challengeResponse.
//! 3. Launcher sends LaunchTokenRequest with nonce + challengeResponse.
//! 4. API validates nonce freshness + response correctness.
//!
//! To jest warstwa UX/speed-bump, NIE twarda bariera.

use crate::integrity;

/// Oblicza challenge response: SHA-256(nonce + ":" + filesHash).
///
/// `nonce` — jednorazowy token z /challenge.php.
/// `files_hash` — filesHash obliczony lokalnie.
///
/// Zwraca hex-encoded SHA-256.
pub fn compute_challenge_response(nonce: &str, files_hash: &str) -> String {
    let input = format!("{}:{}", nonce, files_hash);
    integrity::sha256_bytes(input.as_bytes())
}

/// Waliduje format nonce (minimum 32 znaki hex).
pub fn validate_nonce(nonce: &str) -> Result<(), ChallengeError> {
    if nonce.is_empty() {
        return Err(ChallengeError::EmptyNonce);
    }
    if nonce.len() < 32 {
        return Err(ChallengeError::NonceTooShort {
            len: nonce.len(),
            min: 32,
        });
    }
    // Nonce powinien być hex
    if !nonce.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(ChallengeError::NonceNotHex);
    }
    Ok(())
}

/// Sprawdza czy challenge response jest poprawny (weryfikacja lokalna).
///
/// Używane do self-check przed wysłaniem requestu.
pub fn verify_challenge_response(nonce: &str, files_hash: &str, response: &str) -> bool {
    let expected = compute_challenge_response(nonce, files_hash);
    expected.eq_ignore_ascii_case(response)
}

/// Błędy challenge-response.
#[derive(Debug, thiserror::Error)]
pub enum ChallengeError {
    #[error("Empty nonce")]
    EmptyNonce,

    #[error("Nonce too short: {len} chars (min {min})")]
    NonceTooShort { len: usize, min: usize },

    #[error("Nonce is not valid hex")]
    NonceNotHex,

    #[error("Challenge expired")]
    Expired,

    #[error("Challenge fetch failed: {0}")]
    FetchFailed(String),
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compute_challenge_response() {
        let nonce = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4";
        let files_hash = "deadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678";
        let result = compute_challenge_response(nonce, files_hash);

        // Musi być 64-znakowy hex (SHA-256)
        assert_eq!(result.len(), 64);
        assert!(result.chars().all(|c| c.is_ascii_hexdigit()));
    }

    #[test]
    fn test_challenge_response_deterministic() {
        let nonce = "aaaa1111bbbb2222cccc3333dddd4444";
        let hash = "eeee5555ffff6666";
        let r1 = compute_challenge_response(nonce, hash);
        let r2 = compute_challenge_response(nonce, hash);
        assert_eq!(r1, r2);
    }

    #[test]
    fn test_challenge_response_changes_with_nonce() {
        let hash = "samyhash";
        let r1 = compute_challenge_response("aaaa1111bbbb2222cccc3333dddd4444", hash);
        let r2 = compute_challenge_response("eeee5555ffff6666aaaa1111bbbb2222", hash);
        assert_ne!(r1, r2);
    }

    #[test]
    fn test_challenge_response_changes_with_hash() {
        let nonce = "aaaa1111bbbb2222cccc3333dddd4444";
        let r1 = compute_challenge_response(nonce, "hash_a");
        let r2 = compute_challenge_response(nonce, "hash_b");
        assert_ne!(r1, r2);
    }

    #[test]
    fn test_verify_challenge_response_ok() {
        let nonce = "aaaa1111bbbb2222cccc3333dddd4444";
        let hash = "myhash";
        let response = compute_challenge_response(nonce, hash);
        assert!(verify_challenge_response(nonce, hash, &response));
    }

    #[test]
    fn test_verify_challenge_response_case_insensitive() {
        let nonce = "aaaa1111bbbb2222cccc3333dddd4444";
        let hash = "myhash";
        let response = compute_challenge_response(nonce, hash).to_uppercase();
        assert!(verify_challenge_response(nonce, hash, &response));
    }

    #[test]
    fn test_verify_challenge_response_fail() {
        let nonce = "aaaa1111bbbb2222cccc3333dddd4444";
        assert!(!verify_challenge_response(nonce, "hash", "wrong_response"));
    }

    #[test]
    fn test_validate_nonce_ok() {
        let nonce = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4";
        assert!(validate_nonce(nonce).is_ok());
    }

    #[test]
    fn test_validate_nonce_empty() {
        assert!(matches!(
            validate_nonce(""),
            Err(ChallengeError::EmptyNonce)
        ));
    }

    #[test]
    fn test_validate_nonce_too_short() {
        assert!(matches!(
            validate_nonce("abc123"),
            Err(ChallengeError::NonceTooShort { .. })
        ));
    }

    #[test]
    fn test_validate_nonce_not_hex() {
        assert!(matches!(
            validate_nonce("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"),
            Err(ChallengeError::NonceNotHex)
        ));
    }
}
