//! LR-058..060: Konfiguracja rollout — kanały i stopniowe wdrażanie.
//!
//! Model danych dla:
//! - Konfiguracji kanałów (dev/test/stable)
//! - Rollout procentowy (A/B testing)
//! - Auto-rollback thresholds
//! - Fallback do Python launchera

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Główna konfiguracja rollout — pobierana z API lub pliku.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RolloutConfig {
    /// Wersja konfiguracji.
    pub version: String,
    /// Data aktualizacji (ISO-8601).
    pub updated_at: String,
    /// Konfiguracja per kanał.
    pub channels: HashMap<String, ChannelRollout>,
}

/// Konfiguracja rollout dla jednego kanału.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChannelRollout {
    /// Typ launchera: "rust" lub "python".
    pub launcher: String,
    /// Minimalna wersja launchera.
    #[serde(default)]
    pub min_launcher_version: Option<String>,
    /// Czy kanał jest aktywny.
    #[serde(default = "default_true")]
    pub enabled: bool,
    /// Procent użytkowników na Rust launcher (0-100).
    #[serde(default)]
    pub rollout_percentage: Option<u8>,
    /// Seed do determinowania grupy A/B (np. "user_id_hash_mod_100").
    #[serde(default)]
    pub rollout_seed: Option<String>,
    /// Fallback launcher type.
    #[serde(default)]
    pub fallback_launcher: Option<String>,
    /// Czy fallback do Python jest aktywny.
    #[serde(default)]
    pub fallback_to_rust: Option<bool>,
    /// Allowlist użytkowników (testing).
    #[serde(default)]
    pub allowlist: Vec<String>,
    /// Progi auto-rollback.
    #[serde(default)]
    pub auto_rollback_threshold: Option<AutoRollbackThreshold>,
    /// Data końca fallbacku do Python (ISO-8601).
    #[serde(default)]
    pub python_fallback_end_date: Option<String>,
}

/// Progi auto-rollback.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AutoRollbackThreshold {
    /// Max acceptable token rejection rate (0.0 - 1.0).
    pub token_reject_rate: f64,
    /// Max acceptable update failure rate (0.0 - 1.0).
    pub update_fail_rate: f64,
}

fn default_true() -> bool {
    true
}

/// Sprawdza czy użytkownik powinien używać Rust launchera
/// na podstawie rollout config i hashu identyfikatora.
pub fn should_use_rust_launcher(
    channel_config: &ChannelRollout,
    user_identifier: &str,
) -> bool {
    // Sprawdź czy kanał jest aktywny
    if !channel_config.enabled {
        return false;
    }

    // Sprawdź launcher type
    if channel_config.launcher != "rust" {
        return false;
    }

    // Sprawdź allowlist (jeśli niepusta, tylko ci użytkownicy)
    if !channel_config.allowlist.is_empty() {
        return channel_config.allowlist.iter().any(|a| a == user_identifier);
    }

    // Sprawdź rollout procentowy
    if let Some(percentage) = channel_config.rollout_percentage {
        if percentage >= 100 {
            return true;
        }
        if percentage == 0 {
            return false;
        }
        // Deterministyczny hash → modulo
        let hash = simple_hash(user_identifier);
        let bucket = (hash % 100) as u8;
        return bucket < percentage;
    }

    // Brak ograniczeń → OK
    true
}

/// Prosty deterministyczny hash (nie kryptograficzny, wystarczy do bucket assignment).
fn simple_hash(input: &str) -> u64 {
    // FNV-1a hash
    let mut hash: u64 = 14695981039346656037;
    for byte in input.bytes() {
        hash ^= byte as u64;
        hash = hash.wrapping_mul(1099511628211);
    }
    hash
}

/// Walidacja konfiguracji rollout.
pub fn validate_rollout_config(config: &RolloutConfig) -> Result<(), Vec<String>> {
    let mut errors = Vec::new();

    if config.version.is_empty() {
        errors.push("version is empty".to_string());
    }

    if config.channels.is_empty() {
        errors.push("no channels defined".to_string());
    }

    for (name, channel) in &config.channels {
        if channel.launcher != "rust" && channel.launcher != "python" {
            errors.push(format!(
                "channel '{}': invalid launcher type '{}'",
                name, channel.launcher
            ));
        }

        if let Some(pct) = channel.rollout_percentage {
            if pct > 100 {
                errors.push(format!(
                    "channel '{}': rollout_percentage {} > 100",
                    name, pct
                ));
            }
        }

        if let Some(ref threshold) = channel.auto_rollback_threshold {
            if threshold.token_reject_rate < 0.0 || threshold.token_reject_rate > 1.0 {
                errors.push(format!(
                    "channel '{}': token_reject_rate out of range [0,1]",
                    name
                ));
            }
            if threshold.update_fail_rate < 0.0 || threshold.update_fail_rate > 1.0 {
                errors.push(format!(
                    "channel '{}': update_fail_rate out of range [0,1]",
                    name
                ));
            }
        }
    }

    if errors.is_empty() {
        Ok(())
    } else {
        Err(errors)
    }
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    fn simple_channel(launcher: &str, percentage: Option<u8>) -> ChannelRollout {
        ChannelRollout {
            launcher: launcher.to_string(),
            min_launcher_version: None,
            enabled: true,
            rollout_percentage: percentage,
            rollout_seed: None,
            fallback_launcher: None,
            fallback_to_rust: None,
            allowlist: vec![],
            auto_rollback_threshold: None,
            python_fallback_end_date: None,
        }
    }

    #[test]
    fn test_rust_launcher_100_percent() {
        let config = simple_channel("rust", Some(100));
        assert!(should_use_rust_launcher(&config, "any_user"));
    }

    #[test]
    fn test_rust_launcher_0_percent() {
        let config = simple_channel("rust", Some(0));
        assert!(!should_use_rust_launcher(&config, "any_user"));
    }

    #[test]
    fn test_python_launcher_always_false() {
        let config = simple_channel("python", None);
        assert!(!should_use_rust_launcher(&config, "any_user"));
    }

    #[test]
    fn test_disabled_channel() {
        let mut config = simple_channel("rust", Some(100));
        config.enabled = false;
        assert!(!should_use_rust_launcher(&config, "any_user"));
    }

    #[test]
    fn test_allowlist_match() {
        let mut config = simple_channel("rust", None);
        config.allowlist = vec!["tester1".to_string(), "tester2".to_string()];
        assert!(should_use_rust_launcher(&config, "tester1"));
        assert!(!should_use_rust_launcher(&config, "unknown_user"));
    }

    #[test]
    fn test_rollout_percentage_deterministic() {
        let config = simple_channel("rust", Some(50));
        let result1 = should_use_rust_launcher(&config, "user_abc");
        let result2 = should_use_rust_launcher(&config, "user_abc");
        assert_eq!(result1, result2); // Deterministic
    }

    #[test]
    fn test_rollout_percentage_distribution() {
        let config = simple_channel("rust", Some(50));
        let mut rust_count = 0;
        for i in 0..1000 {
            if should_use_rust_launcher(&config, &format!("user_{}", i)) {
                rust_count += 1;
            }
        }
        // Z 50% rollout, powinno trafić ~500 (+/- margines)
        assert!(rust_count > 350 && rust_count < 650,
            "Expected ~500, got {}", rust_count);
    }

    #[test]
    fn test_validate_rollout_config_ok() {
        let config = RolloutConfig {
            version: "1.0".to_string(),
            updated_at: "2026-03-03T12:00:00Z".to_string(),
            channels: {
                let mut m = HashMap::new();
                m.insert("stable".to_string(), simple_channel("rust", Some(100)));
                m
            },
        };
        assert!(validate_rollout_config(&config).is_ok());
    }

    #[test]
    fn test_validate_rollout_config_errors() {
        let config = RolloutConfig {
            version: String::new(),
            updated_at: String::new(),
            channels: {
                let mut m = HashMap::new();
                m.insert("bad".to_string(), simple_channel("invalid", Some(200)));
                m
            },
        };
        let errors = validate_rollout_config(&config).unwrap_err();
        assert!(errors.len() >= 2);
    }

    #[test]
    fn test_serde_roundtrip() {
        let config = RolloutConfig {
            version: "1.0".to_string(),
            updated_at: "2026-03-03T12:00:00Z".to_string(),
            channels: {
                let mut m = HashMap::new();
                m.insert("stable".to_string(), simple_channel("rust", Some(50)));
                m
            },
        };
        let json = serde_json::to_string_pretty(&config).unwrap();
        let parsed: RolloutConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(parsed.version, "1.0");
        assert!(parsed.channels.contains_key("stable"));
    }
}
