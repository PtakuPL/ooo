//! LR-056: Rotacja kluczy HMAC z mechanizmem `kid` (Key ID).
//!
//! Umożliwia:
//! - Walidację ticketów podpisanych różnymi kluczami (multi-key).
//! - Rotację kluczy bez downtime (stary + nowy klucz aktywne jednocześnie).
//! - Wycofanie klucza po okresie przejściowym.
//!
//! Model:
//! - Każdy ticket/token ma nagłówek `kid` identyfikujący klucz.
//! - Launcher przechowuje listę aktywnych kluczy publicznych.
//! - Walidacja próbuje klucza wg `kid`; jeśli brak → próbuje wszystkich.

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::HashMap;

/// Pojedynczy klucz HMAC w rejestrze.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct HmacKey {
    /// Identyfikator klucza (np. "key-2026-01", "key-2026-03").
    pub kid: String,
    /// Klucz w formacie hex.
    pub key_hex: String,
    /// Czy klucz jest aktywny (do podpisywania).
    pub active: bool,
    /// Czy klucz jest wycofany (do weryfikacji: tak, do podpisywania: nie).
    pub deprecated: bool,
    /// Data dodania klucza (ISO-8601).
    #[serde(default)]
    pub added_at: Option<String>,
    /// Data wycofania klucza (ISO-8601, None = aktywny).
    #[serde(default)]
    pub deprecated_at: Option<String>,
}

/// Rejestr kluczy HMAC.
#[derive(Debug, Clone)]
pub struct HmacKeyRegistry {
    keys: HashMap<String, HmacKey>,
}

impl HmacKeyRegistry {
    /// Tworzy pusty rejestr.
    pub fn new() -> Self {
        Self {
            keys: HashMap::new(),
        }
    }

    /// Tworzy rejestr z listy kluczy.
    pub fn from_keys(keys: Vec<HmacKey>) -> Self {
        let map = keys.into_iter().map(|k| (k.kid.clone(), k)).collect();
        Self { keys: map }
    }

    /// Dodaje klucz do rejestru.
    pub fn add_key(&mut self, key: HmacKey) {
        self.keys.insert(key.kid.clone(), key);
    }

    /// Wycofuje klucz (deprecated = true, active = false).
    pub fn deprecate_key(&mut self, kid: &str) -> bool {
        if let Some(key) = self.keys.get_mut(kid) {
            key.active = false;
            key.deprecated = true;
            true
        } else {
            false
        }
    }

    /// Usuwa klucz z rejestru (po pełnym wycofaniu).
    pub fn remove_key(&mut self, kid: &str) -> bool {
        self.keys.remove(kid).is_some()
    }

    /// Pobiera klucz po kid.
    pub fn get_key(&self, kid: &str) -> Option<&HmacKey> {
        self.keys.get(kid)
    }

    /// Pobiera aktywny klucz do podpisywania (najnowszy aktywny).
    pub fn get_signing_key(&self) -> Option<&HmacKey> {
        self.keys.values().find(|k| k.active && !k.deprecated)
    }

    /// Pobiera wszystkie klucze do weryfikacji (aktywne + deprecated).
    pub fn get_verification_keys(&self) -> Vec<&HmacKey> {
        self.keys.values().collect()
    }

    /// Ilość kluczy w rejestrze.
    pub fn len(&self) -> usize {
        self.keys.len()
    }

    /// Czy rejestr jest pusty.
    pub fn is_empty(&self) -> bool {
        self.keys.is_empty()
    }
}

impl Default for HmacKeyRegistry {
    fn default() -> Self {
        Self::new()
    }
}

/// Oblicza HMAC-SHA256 dla danych z podanym kluczem.
pub fn hmac_sha256(key_hex: &str, data: &[u8]) -> Result<String, HmacKeyError> {
    let key_bytes = hex_decode(key_hex)?;
    // Prosta implementacja HMAC (FIPS 198-1):
    // HMAC(K, m) = H((K' XOR opad) || H((K' XOR ipad) || m))
    let block_size = 64; // SHA-256 block size
    let mut key_padded = if key_bytes.len() > block_size {
        let mut h = Sha256::new();
        h.update(&key_bytes);
        h.finalize().to_vec()
    } else {
        key_bytes.clone()
    };
    key_padded.resize(block_size, 0);

    let ipad: Vec<u8> = key_padded.iter().map(|b| b ^ 0x36).collect();
    let opad: Vec<u8> = key_padded.iter().map(|b| b ^ 0x5c).collect();

    // Inner hash
    let mut inner = Sha256::new();
    inner.update(&ipad);
    inner.update(data);
    let inner_result = inner.finalize();

    // Outer hash
    let mut outer = Sha256::new();
    outer.update(&opad);
    outer.update(inner_result);
    let result = outer.finalize();

    Ok(format!("{:x}", result))
}

/// Weryfikuje HMAC z automatycznym doborem klucza wg `kid`.
///
/// Jeśli `kid` jest podany → używa tego klucza.
/// Jeśli brak `kid` → próbuje wszystkich kluczy (brute-force, ale mała lista).
pub fn verify_hmac(
    registry: &HmacKeyRegistry,
    kid: Option<&str>,
    data: &[u8],
    expected_hmac: &str,
) -> Result<HmacVerifyResult, HmacKeyError> {
    // Jeśli kid podany — szukaj konkretnego klucza
    if let Some(kid) = kid {
        if let Some(key) = registry.get_key(kid) {
            let computed = hmac_sha256(&key.key_hex, data)?;
            let valid = computed.eq_ignore_ascii_case(expected_hmac);
            return Ok(HmacVerifyResult {
                valid,
                matched_kid: if valid { Some(kid.to_string()) } else { None },
                keys_tried: 1,
            });
        } else {
            return Ok(HmacVerifyResult {
                valid: false,
                matched_kid: None,
                keys_tried: 0,
            });
        }
    }

    // Brak kid — próbuj wszystkich kluczy
    let verification_keys = registry.get_verification_keys();
    let mut keys_tried = 0;

    for key in &verification_keys {
        keys_tried += 1;
        if let Ok(computed) = hmac_sha256(&key.key_hex, data) {
            if computed.eq_ignore_ascii_case(expected_hmac) {
                return Ok(HmacVerifyResult {
                    valid: true,
                    matched_kid: Some(key.kid.clone()),
                    keys_tried,
                });
            }
        }
    }

    Ok(HmacVerifyResult {
        valid: false,
        matched_kid: None,
        keys_tried,
    })
}

/// Wynik weryfikacji HMAC.
#[derive(Debug, Clone)]
pub struct HmacVerifyResult {
    /// Czy HMAC jest poprawny.
    pub valid: bool,
    /// Kid klucza, który pasował (None jeśli brak).
    pub matched_kid: Option<String>,
    /// Ilość kluczy, które zostały sprawdzone.
    pub keys_tried: usize,
}

/// Błędy operacji na kluczach HMAC.
#[derive(Debug, thiserror::Error)]
pub enum HmacKeyError {
    #[error("Invalid hex key: {0}")]
    InvalidHex(String),

    #[error("Key not found: {0}")]
    KeyNotFound(String),

    #[error("No active signing key")]
    NoSigningKey,
}

/// Dekoduje hex string na bajty.
fn hex_decode(hex: &str) -> Result<Vec<u8>, HmacKeyError> {
    if !hex.len().is_multiple_of(2) {
        return Err(HmacKeyError::InvalidHex("odd length".to_string()));
    }
    (0..hex.len())
        .step_by(2)
        .map(|i| {
            u8::from_str_radix(&hex[i..i + 2], 16)
                .map_err(|e| HmacKeyError::InvalidHex(format!("at pos {}: {}", i, e)))
        })
        .collect()
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn test_key(kid: &str, active: bool, deprecated: bool) -> HmacKey {
        HmacKey {
            kid: kid.to_string(),
            key_hex: "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef".to_string(),
            active,
            deprecated,
            added_at: None,
            deprecated_at: None,
        }
    }

    #[test]
    fn test_registry_add_and_get() {
        let mut registry = HmacKeyRegistry::new();
        assert!(registry.is_empty());

        registry.add_key(test_key("key-1", true, false));
        assert_eq!(registry.len(), 1);
        assert!(registry.get_key("key-1").is_some());
        assert!(registry.get_key("key-2").is_none());
    }

    #[test]
    fn test_registry_from_keys() {
        let keys = vec![
            test_key("key-1", true, false),
            test_key("key-2", false, true),
        ];
        let registry = HmacKeyRegistry::from_keys(keys);
        assert_eq!(registry.len(), 2);
    }

    #[test]
    fn test_deprecate_key() {
        let mut registry = HmacKeyRegistry::new();
        registry.add_key(test_key("key-1", true, false));
        assert!(registry.deprecate_key("key-1"));
        let key = registry.get_key("key-1").unwrap();
        assert!(!key.active);
        assert!(key.deprecated);
    }

    #[test]
    fn test_remove_key() {
        let mut registry = HmacKeyRegistry::new();
        registry.add_key(test_key("key-1", true, false));
        assert!(registry.remove_key("key-1"));
        assert!(registry.is_empty());
    }

    #[test]
    fn test_get_signing_key() {
        let mut registry = HmacKeyRegistry::new();
        registry.add_key(test_key("key-old", false, true));
        registry.add_key(test_key("key-new", true, false));

        let signing = registry.get_signing_key().unwrap();
        assert_eq!(signing.kid, "key-new");
    }

    #[test]
    fn test_get_signing_key_none() {
        let mut registry = HmacKeyRegistry::new();
        registry.add_key(test_key("key-old", false, true));
        assert!(registry.get_signing_key().is_none());
    }

    #[test]
    fn test_hmac_sha256_deterministic() {
        let key = "0123456789abcdef0123456789abcdef";
        let data = b"test message";
        let h1 = hmac_sha256(key, data).unwrap();
        let h2 = hmac_sha256(key, data).unwrap();
        assert_eq!(h1, h2);
        assert_eq!(h1.len(), 64); // SHA-256 hex
    }

    #[test]
    fn test_hmac_sha256_different_keys() {
        let data = b"test message";
        let h1 = hmac_sha256("0123456789abcdef0123456789abcdef", data).unwrap();
        let h2 = hmac_sha256("abcdef0123456789abcdef0123456789", data).unwrap();
        assert_ne!(h1, h2);
    }

    #[test]
    fn test_verify_hmac_with_kid() {
        let key_hex = "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef";
        let data = b"hello world";
        let expected = hmac_sha256(key_hex, data).unwrap();

        let mut registry = HmacKeyRegistry::new();
        registry.add_key(HmacKey {
            kid: "key-1".to_string(),
            key_hex: key_hex.to_string(),
            active: true,
            deprecated: false,
            added_at: None,
            deprecated_at: None,
        });

        let result = verify_hmac(&registry, Some("key-1"), data, &expected).unwrap();
        assert!(result.valid);
        assert_eq!(result.matched_kid.as_deref(), Some("key-1"));
        assert_eq!(result.keys_tried, 1);
    }

    #[test]
    fn test_verify_hmac_without_kid_tries_all() {
        let key_hex = "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789";
        let data = b"hello world";
        let expected = hmac_sha256(key_hex, data).unwrap();

        let mut registry = HmacKeyRegistry::new();
        registry.add_key(HmacKey {
            kid: "key-wrong".to_string(),
            key_hex: "0000000000000000000000000000000000000000000000000000000000000000".to_string(),
            active: false,
            deprecated: true,
            added_at: None,
            deprecated_at: None,
        });
        registry.add_key(HmacKey {
            kid: "key-right".to_string(),
            key_hex: key_hex.to_string(),
            active: true,
            deprecated: false,
            added_at: None,
            deprecated_at: None,
        });

        let result = verify_hmac(&registry, None, data, &expected).unwrap();
        assert!(result.valid);
        assert_eq!(result.matched_kid.as_deref(), Some("key-right"));
    }

    #[test]
    fn test_challenge_with_rotated_key() {
        let old_key = "1111111111111111111111111111111111111111111111111111111111111111";
        let new_key = "2222222222222222222222222222222222222222222222222222222222222222";
        let challenge_payload = b"a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4:deadbeefcafebabe";

        let old_sig = hmac_sha256(old_key, challenge_payload).unwrap();
        let new_sig = hmac_sha256(new_key, challenge_payload).unwrap();
        assert_ne!(old_sig, new_sig);

        let mut registry = HmacKeyRegistry::new();
        registry.add_key(HmacKey {
            kid: "key-2026-01".to_string(),
            key_hex: old_key.to_string(),
            active: false,
            deprecated: true,
            added_at: Some("2026-01-01T00:00:00Z".to_string()),
            deprecated_at: Some("2026-03-01T00:00:00Z".to_string()),
        });
        registry.add_key(HmacKey {
            kid: "key-2026-03".to_string(),
            key_hex: new_key.to_string(),
            active: true,
            deprecated: false,
            added_at: Some("2026-03-01T00:00:00Z".to_string()),
            deprecated_at: None,
        });

        // Klient na starym kluczu (kid=old) nadal przechodzi w okresie rotacji.
        let old_result =
            verify_hmac(&registry, Some("key-2026-01"), challenge_payload, &old_sig).unwrap();
        assert!(old_result.valid);
        assert_eq!(old_result.matched_kid.as_deref(), Some("key-2026-01"));

        // Klient na nowym kluczu (kid=new) przechodzi normalnie.
        let new_result =
            verify_hmac(&registry, Some("key-2026-03"), challenge_payload, &new_sig).unwrap();
        assert!(new_result.valid);
        assert_eq!(new_result.matched_kid.as_deref(), Some("key-2026-03"));

        // Brak kid: fallback brute-force nadal akceptuje podpis ze starego klucza.
        let legacy_result = verify_hmac(&registry, None, challenge_payload, &old_sig).unwrap();
        assert!(legacy_result.valid);
        assert_eq!(legacy_result.matched_kid.as_deref(), Some("key-2026-01"));
        assert!(legacy_result.keys_tried >= 1);
    }

    #[test]
    fn test_verify_hmac_no_match() {
        let mut registry = HmacKeyRegistry::new();
        registry.add_key(test_key("key-1", true, false));

        let result = verify_hmac(&registry, None, b"data", "incorrect_hmac").unwrap();
        assert!(!result.valid);
        assert!(result.matched_kid.is_none());
    }
}
