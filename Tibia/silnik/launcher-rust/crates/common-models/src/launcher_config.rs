//! Konfiguracja launchera (LR-042: integracja z instalką).
//!
//! `launcher_config.json` jest tworzony przez installer bootstrap
//! i zawiera minimalną konfigurację potrzebną do startu launchera.

use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};

/// Konfiguracja launchera ładowana z `launcher_config.json`.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LauncherConfig {
    /// Bazowy URL API launchera (np. "https://api.serwercanary.pl/client/").
    pub api_base_url: String,

    /// Kanał aktualizacji: "stable", "test", "dev".
    #[serde(default = "default_channel")]
    pub channel: String,

    /// Czy sprawdzać wersję launchera przy starcie.
    #[serde(default = "default_true")]
    pub launcher_version_check: bool,

    /// Ścieżka katalogu klienta (względna do exe lub bezwzględna).
    #[serde(default = "default_client_dir")]
    pub client_dir: String,

    /// Ścieżka katalogu danych launchera.
    #[serde(default = "default_launcher_data_dir")]
    pub launcher_data_dir: String,
}

fn default_channel() -> String {
    "stable".to_string()
}

fn default_true() -> bool {
    true
}

fn default_client_dir() -> String {
    "client".to_string()
}

fn default_launcher_data_dir() -> String {
    "launcher_data".to_string()
}

impl Default for LauncherConfig {
    fn default() -> Self {
        Self {
            api_base_url: "https://api.serwercanary.pl/client/".to_string(),
            channel: default_channel(),
            launcher_version_check: true,
            client_dir: default_client_dir(),
            launcher_data_dir: default_launcher_data_dir(),
        }
    }
}

impl LauncherConfig {
    /// Ładuje config z pliku JSON.
    pub fn load_from_file(path: &Path) -> Result<Self, ConfigError> {
        let content = std::fs::read_to_string(path).map_err(|e| ConfigError::Io {
            path: path.to_path_buf(),
            source: e,
        })?;
        let config: Self = serde_json::from_str(&content).map_err(|e| ConfigError::Parse {
            path: path.to_path_buf(),
            source: e,
        })?;
        config.validate()?;
        Ok(config)
    }

    /// Zapisuje config do pliku JSON (pretty-print).
    pub fn save_to_file(&self, path: &Path) -> Result<(), ConfigError> {
        let content = serde_json::to_string_pretty(self).map_err(|e| ConfigError::Parse {
            path: path.to_path_buf(),
            source: e,
        })?;
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| ConfigError::Io {
                path: path.to_path_buf(),
                source: e,
            })?;
        }
        std::fs::write(path, content).map_err(|e| ConfigError::Io {
            path: path.to_path_buf(),
            source: e,
        })?;
        Ok(())
    }

    /// Szuka i ładuje config z domyślnych lokalizacji:
    /// 1. Obok binarki launchera
    /// 2. W katalogu nadrzędnym
    pub fn discover(exe_dir: &Path) -> Result<Self, ConfigError> {
        let candidates = [
            exe_dir.join("launcher_config.json"),
            exe_dir
                .parent()
                .map(|p| p.join("launcher_config.json"))
                .unwrap_or_default(),
        ];

        for path in &candidates {
            if path.exists() {
                return Self::load_from_file(path);
            }
        }

        // Brak configu — użyj domyślnych wartości
        tracing::warn!("Nie znaleziono launcher_config.json — używam domyślnych ustawień");
        Ok(Self::default())
    }

    /// Waliduje pola konfiguracji.
    pub fn validate(&self) -> Result<(), ConfigError> {
        if self.api_base_url.is_empty() {
            return Err(ConfigError::Validation(
                "api_base_url nie może być pusty".into(),
            ));
        }
        if !["stable", "test", "dev"].contains(&self.channel.as_str()) {
            return Err(ConfigError::Validation(format!(
                "Nieprawidłowy kanał: '{}' (dozwolone: stable, test, dev)",
                self.channel
            )));
        }
        if self.client_dir.is_empty() {
            return Err(ConfigError::Validation(
                "client_dir nie może być pusty".into(),
            ));
        }
        if self.launcher_data_dir.is_empty() {
            return Err(ConfigError::Validation(
                "launcher_data_dir nie może być pusty".into(),
            ));
        }
        Ok(())
    }

    /// Resolves client_dir relative to a base directory.
    pub fn resolve_client_dir(&self, base: &Path) -> PathBuf {
        let p = Path::new(&self.client_dir);
        if p.is_absolute() {
            p.to_path_buf()
        } else {
            base.join(p)
        }
    }

    /// Resolves launcher_data_dir relative to a base directory.
    pub fn resolve_data_dir(&self, base: &Path) -> PathBuf {
        let p = Path::new(&self.launcher_data_dir);
        if p.is_absolute() {
            p.to_path_buf()
        } else {
            base.join(p)
        }
    }
}

/// Błędy konfiguracji launchera.
#[derive(Debug, thiserror::Error)]
pub enum ConfigError {
    #[error("I/O error reading config at {path}: {source}")]
    Io {
        path: PathBuf,
        source: std::io::Error,
    },

    #[error("JSON parse error in config at {path}: {source}")]
    Parse {
        path: PathBuf,
        source: serde_json::Error,
    },

    #[error("Config validation error: {0}")]
    Validation(String),
}

// ─────────────────────────────────────────
// Testy
// ─────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = LauncherConfig::default();
        assert_eq!(config.channel, "stable");
        assert!(config.launcher_version_check);
        assert_eq!(config.client_dir, "client");
        assert_eq!(config.launcher_data_dir, "launcher_data");
        assert!(config.validate().is_ok());
    }

    #[test]
    fn test_config_roundtrip_json() {
        let config = LauncherConfig::default();
        let json = serde_json::to_string_pretty(&config).unwrap();
        let parsed: LauncherConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(config.api_base_url, parsed.api_base_url);
        assert_eq!(config.channel, parsed.channel);
    }

    #[test]
    fn test_config_minimal_json() {
        let json = r#"{"apiBaseUrl": "https://api.example.com/"}"#;
        let config: LauncherConfig = serde_json::from_str(json).unwrap();
        assert_eq!(config.api_base_url, "https://api.example.com/");
        assert_eq!(config.channel, "stable");
        assert_eq!(config.client_dir, "client");
    }

    #[test]
    fn test_config_validation_empty_url() {
        let config = LauncherConfig {
            api_base_url: String::new(),
            ..LauncherConfig::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_config_validation_bad_channel() {
        let config = LauncherConfig {
            channel: "beta".to_string(),
            ..LauncherConfig::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_resolve_relative_dirs() {
        let config = LauncherConfig::default();
        let base = Path::new("/opt/serwercanary");
        assert_eq!(
            config.resolve_client_dir(base),
            PathBuf::from("/opt/serwercanary/client")
        );
        assert_eq!(
            config.resolve_data_dir(base),
            PathBuf::from("/opt/serwercanary/launcher_data")
        );
    }

    #[test]
    fn test_resolve_absolute_dirs() {
        let config = LauncherConfig {
            client_dir: "/custom/path/client".to_string(),
            launcher_data_dir: "/custom/data".to_string(),
            ..Default::default()
        };
        let base = Path::new("/opt/serwercanary");
        assert_eq!(
            config.resolve_client_dir(base),
            PathBuf::from("/custom/path/client")
        );
    }
}
