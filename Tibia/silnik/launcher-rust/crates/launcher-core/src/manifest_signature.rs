//! LR-053: Weryfikacja podpisu manifestu (defense-in-depth).
//!
//! Model podpisów:
//! - Level 1: SHA-256 hash check (already in integrity module)
//! - Level 2: Ed25519 detached signature (.sig)
//! - Level 3: Full PKI (future, opcjonalne)
//!
//! Ten moduł obsługuje Level 2 — weryfikację podpisu Ed25519
//! dołączonego do manifestu w polu `signature`.

use crate::integrity;

/// Wynik weryfikacji podpisu manifestu.
#[derive(Debug, Clone)]
pub struct ManifestSignatureResult {
    /// Czy podpis jest obecny.
    pub signature_present: bool,
    /// Czy podpis jest poprawny (None jeśli brak podpisu lub klucza).
    pub signature_valid: Option<bool>,
    /// Hash SHA-256 treści manifestu.
    pub manifest_hash: String,
    /// Komunikat diagnostyczny.
    pub message: String,
}

/// Polityka weryfikacji podpisu.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum SignaturePolicy {
    /// Podpis ignorowany (tryb legacy).
    Ignore,
    /// Podpis sprawdzany jeśli obecny, brak podpisu = OK.
    WarnIfMissing,
    /// Podpis wymagany — brak lub niepoprawny = błąd.
    Require,
}

/// Błędy weryfikacji podpisu manifestu.
#[derive(Debug, thiserror::Error)]
pub enum SignatureError {
    #[error("Manifest signature missing (policy: require)")]
    SignatureMissing,

    #[error("Manifest signature invalid")]
    SignatureInvalid,

    #[error("Signature decode error: {0}")]
    DecodeError(String),

    #[error("Public key not configured")]
    NoPublicKey,

    #[error("Public key format error: {0}")]
    KeyFormatError(String),
}

/// Konfiguracja weryfikacji podpisu.
#[derive(Debug, Clone)]
pub struct SignatureConfig {
    /// Polityka weryfikacji.
    pub policy: SignaturePolicy,
    /// Klucz publiczny Ed25519 w formacie hex (64 znaki = 32 bajty).
    pub public_key_hex: Option<String>,
}

impl Default for SignatureConfig {
    fn default() -> Self {
        Self {
            policy: SignaturePolicy::Ignore,
            public_key_hex: None,
        }
    }
}

/// Weryfikuje podpis manifestu wg ustawionej polityki.
///
/// `manifest_json` — surowy JSON manifestu (tekst).
/// `signature_hex` — opcjonalny podpis z pola `signature` (hex-encoded Ed25519).
/// `config` — konfiguracja polityki i klucza publicznego.
pub fn verify_manifest_signature(
    manifest_json: &str,
    signature_hex: Option<&str>,
    config: &SignatureConfig,
) -> Result<ManifestSignatureResult, SignatureError> {
    let manifest_hash = integrity::sha256_bytes(manifest_json.as_bytes());

    // Tryb Ignore — zawsze OK
    if config.policy == SignaturePolicy::Ignore {
        return Ok(ManifestSignatureResult {
            signature_present: signature_hex.is_some(),
            signature_valid: None,
            manifest_hash,
            message: "Signature policy: ignore".to_string(),
        });
    }

    // Brak podpisu
    match signature_hex {
        None | Some("") => {
            if config.policy == SignaturePolicy::Require {
                return Err(SignatureError::SignatureMissing);
            }
            // WarnIfMissing
            Ok(ManifestSignatureResult {
                signature_present: false,
                signature_valid: None,
                manifest_hash,
                message: "Signature missing (warn mode)".to_string(),
            })
        }
        Some(sig) => {
            // Mamy podpis — potrzebujemy klucza
            let pub_key_hex = config
                .public_key_hex
                .as_deref()
                .ok_or(SignatureError::NoPublicKey)?;

            // Weryfikacja formatu klucza (64 hex = 32 bajtów)
            if pub_key_hex.len() != 64 || !pub_key_hex.chars().all(|c| c.is_ascii_hexdigit()) {
                return Err(SignatureError::KeyFormatError(format!(
                    "Expected 64 hex chars, got {} chars",
                    pub_key_hex.len()
                )));
            }

            // Weryfikacja formatu podpisu (128 hex = 64 bajtów Ed25519)
            if sig.len() != 128 || !sig.chars().all(|c| c.is_ascii_hexdigit()) {
                return Err(SignatureError::DecodeError(format!(
                    "Expected 128 hex chars for Ed25519 signature, got {} chars",
                    sig.len()
                )));
            }

            // Dekodowanie klucza publicznego i podpisu z hex
            let pub_key_bytes = hex_decode(pub_key_hex)
                .map_err(|e| SignatureError::KeyFormatError(e.to_string()))?;
            let sig_bytes =
                hex_decode(sig).map_err(|e| SignatureError::DecodeError(e.to_string()))?;

            // Weryfikacja Ed25519
            // UWAGA: W pełnej implementacji tu byłoby ed25519-dalek::verify.
            // Na razie placeholder sprawdzający format + HMAC-SHA256 jako interim.
            let is_valid =
                verify_ed25519_placeholder(manifest_json.as_bytes(), &sig_bytes, &pub_key_bytes);

            if !is_valid && config.policy == SignaturePolicy::Require {
                return Err(SignatureError::SignatureInvalid);
            }

            Ok(ManifestSignatureResult {
                signature_present: true,
                signature_valid: Some(is_valid),
                manifest_hash,
                message: if is_valid {
                    "Signature valid".to_string()
                } else {
                    "Signature invalid (warn mode)".to_string()
                },
            })
        }
    }
}

/// Placeholder weryfikacji Ed25519.
///
/// W produkcji: użyj crate `ed25519-dalek` (dodamy w Cargo.toml gdy gotowe).
/// Na razie: sprawdza czy HMAC-SHA256(key, message) == sig (uproszczone).
///
/// WAŻNE: To NIE jest prawdziwe Ed25519 — to tymczasowy placeholder
/// do ustrukturyzowania flow. Prawdziwe Ed25519 w kolejnym etapie.
fn verify_ed25519_placeholder(message: &[u8], signature: &[u8], public_key: &[u8]) -> bool {
    // Placeholder: oblicz HMAC-like = SHA-256(key + message) i porównaj
    // To nie jest kryptograficznie poprawne, ale strukturyzuje flow
    use sha2::{Digest, Sha256};
    let mut hasher = Sha256::new();
    hasher.update(public_key);
    hasher.update(message);
    let expected = hasher.finalize();

    if signature.len() < 32 {
        return false;
    }
    // Porównaj pierwsze 32 bajty
    expected.as_slice() == &signature[..32]
}

/// Dekoduje hex string na bajty.
fn hex_decode(hex: &str) -> Result<Vec<u8>, String> {
    if !hex.len().is_multiple_of(2) {
        return Err("Hex string has odd length".to_string());
    }
    (0..hex.len())
        .step_by(2)
        .map(|i| {
            u8::from_str_radix(&hex[i..i + 2], 16)
                .map_err(|e| format!("Invalid hex at position {}: {}", i, e))
        })
        .collect()
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn test_config(policy: SignaturePolicy) -> SignatureConfig {
        SignatureConfig {
            policy,
            public_key_hex: Some(
                "a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718".to_string(),
            ),
        }
    }

    #[test]
    fn test_ignore_policy_no_signature() {
        let config = SignatureConfig {
            policy: SignaturePolicy::Ignore,
            public_key_hex: None,
        };
        let result = verify_manifest_signature("{}", None, &config).unwrap();
        assert!(!result.signature_present);
        assert!(result.signature_valid.is_none());
    }

    #[test]
    fn test_ignore_policy_with_signature() {
        let config = SignatureConfig {
            policy: SignaturePolicy::Ignore,
            public_key_hex: None,
        };
        let sig = "a".repeat(128);
        let result = verify_manifest_signature("{}", Some(&sig), &config).unwrap();
        assert!(result.signature_present);
        assert!(result.signature_valid.is_none());
    }

    #[test]
    fn test_warn_policy_no_signature() {
        let config = test_config(SignaturePolicy::WarnIfMissing);
        let result = verify_manifest_signature("{}", None, &config).unwrap();
        assert!(!result.signature_present);
        assert!(result.message.contains("missing"));
    }

    #[test]
    fn test_require_policy_no_signature() {
        let config = test_config(SignaturePolicy::Require);
        let result = verify_manifest_signature("{}", None, &config);
        assert!(matches!(result, Err(SignatureError::SignatureMissing)));
    }

    #[test]
    fn test_require_policy_bad_signature_format() {
        let config = test_config(SignaturePolicy::Require);
        let result = verify_manifest_signature("{}", Some("tooshort"), &config);
        assert!(matches!(result, Err(SignatureError::DecodeError(_))));
    }

    #[test]
    fn test_no_public_key() {
        let config = SignatureConfig {
            policy: SignaturePolicy::WarnIfMissing,
            public_key_hex: None,
        };
        let sig = "a".repeat(128);
        let result = verify_manifest_signature("{}", Some(&sig), &config);
        assert!(matches!(result, Err(SignatureError::NoPublicKey)));
    }

    #[test]
    fn test_hex_decode_valid() {
        let decoded = hex_decode("deadbeef").unwrap();
        assert_eq!(decoded, vec![0xde, 0xad, 0xbe, 0xef]);
    }

    #[test]
    fn test_hex_decode_invalid() {
        assert!(hex_decode("xyz").is_err());
    }

    #[test]
    fn test_default_config_is_ignore() {
        let config = SignatureConfig::default();
        assert_eq!(config.policy, SignaturePolicy::Ignore);
        assert!(config.public_key_hex.is_none());
    }

    #[test]
    fn test_manifest_hash_computed() {
        let config = SignatureConfig {
            policy: SignaturePolicy::Ignore,
            public_key_hex: None,
        };
        let result = verify_manifest_signature("{\"test\": true}", None, &config).unwrap();
        assert!(!result.manifest_hash.is_empty());
        assert_eq!(result.manifest_hash.len(), 64);
    }

    // ─── 6.6: Tampered manifest tests ───

    /// Generuje poprawny podpis placeholder (HMAC-SHA256) dla danego manifestu i klucza.
    fn sign_placeholder(manifest_json: &str, key_hex: &str) -> String {
        use sha2::{Digest, Sha256};
        let key_bytes = hex_decode(key_hex).unwrap();
        let mut hasher = Sha256::new();
        hasher.update(&key_bytes);
        hasher.update(manifest_json.as_bytes());
        let hash = hasher.finalize();
        // Ed25519 sig = 64 bytes = 128 hex chars. Placeholder: hash (32b) + padding (32b).
        let mut sig = hash.to_vec();
        sig.extend_from_slice(&[0u8; 32]); // pad to 64 bytes
        sig.iter().map(|b| format!("{:02x}", b)).collect::<String>()
    }

    #[test]
    fn test_valid_signature_accepted() {
        let key = "a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718";
        let manifest = r#"{"version":"1.0.0","files":[]}"#;
        let sig = sign_placeholder(manifest, key);

        let config = SignatureConfig {
            policy: SignaturePolicy::Require,
            public_key_hex: Some(key.to_string()),
        };
        let result = verify_manifest_signature(manifest, Some(&sig), &config).unwrap();
        assert!(result.signature_present);
        assert_eq!(result.signature_valid, Some(true));
        assert!(result.message.contains("valid"));
    }

    #[test]
    fn test_tampered_manifest_rejected_require() {
        let key = "a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718";
        let original = r#"{"version":"1.0.0","files":[]}"#;
        let tampered = r#"{"version":"1.0.0","files":[{"path":"malware.exe"}]}"#;
        let sig = sign_placeholder(original, key);

        let config = SignatureConfig {
            policy: SignaturePolicy::Require,
            public_key_hex: Some(key.to_string()),
        };
        // Podpis oryginalnego manifestu zastosowany do zmienionego → odrzucenie
        let result = verify_manifest_signature(tampered, Some(&sig), &config);
        assert!(matches!(result, Err(SignatureError::SignatureInvalid)));
    }

    #[test]
    fn test_tampered_manifest_warn_mode() {
        let key = "a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718";
        let original = r#"{"version":"1.0.0"}"#;
        let tampered = r#"{"version":"1.0.1"}"#;
        let sig = sign_placeholder(original, key);

        let config = SignatureConfig {
            policy: SignaturePolicy::WarnIfMissing,
            public_key_hex: Some(key.to_string()),
        };
        // WarnIfMissing: tampered → signature_valid=false ale Ok (nie Err)
        let result = verify_manifest_signature(tampered, Some(&sig), &config).unwrap();
        assert!(result.signature_present);
        assert_eq!(result.signature_valid, Some(false));
        assert!(result.message.contains("invalid"));
    }

    #[test]
    fn test_wrong_key_rejected() {
        let key1 = "a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718a1b2c3d4e5f60718";
        let key2 = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        let manifest = r#"{"version":"1.0.0"}"#;
        let sig = sign_placeholder(manifest, key1);

        let config = SignatureConfig {
            policy: SignaturePolicy::Require,
            public_key_hex: Some(key2.to_string()),
        };
        // Podpis z key1, weryfikacja z key2 → odrzucenie
        let result = verify_manifest_signature(manifest, Some(&sig), &config);
        assert!(matches!(result, Err(SignatureError::SignatureInvalid)));
    }
}
