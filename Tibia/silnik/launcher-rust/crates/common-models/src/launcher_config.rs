//! Konfiguracja launchera (LR-042: integracja z instalką).
//!
//! `launcher_config.json` jest tworzony przez installer bootstrap
//! i zawiera minimalną konfigurację potrzebną do startu launchera.

use serde::{Deserialize, Serialize};
use std::path::{Path, PathBuf};

use crate::validation::{validate_channel, validate_url};

/// Konfiguracja pojedynczego profilu runtime (`dev` / `stage` / `prod`).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct LauncherProfileConfig {
    pub api_base_url: String,
    #[serde(default)]
    pub channel: Option<String>,
    #[serde(default)]
    pub dev_mode: Option<bool>,
    #[serde(default)]
    pub launcher_version_check: Option<bool>,
    #[serde(default)]
    pub manifest_public_key: Option<String>,
}

/// Blok profili runtime.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct LauncherProfiles {
    #[serde(default)]
    pub dev: Option<LauncherProfileConfig>,
    #[serde(default)]
    pub stage: Option<LauncherProfileConfig>,
    #[serde(default)]
    pub prod: Option<LauncherProfileConfig>,
}

/// Konfiguracja launchera ładowana z `launcher_config.json`.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct LauncherConfig {
    /// Bazowy URL API launchera (np. "https://api.serwercanary.pl/client/").
    pub api_base_url: String,

    /// Kanał aktualizacji: "stable", "test", "dev".
    #[serde(default = "default_channel")]
    pub channel: String,

    /// Profil runtime: "dev", "stage", "prod".
    #[serde(default = "default_profile")]
    pub profile: String,

    /// Opcjonalny blok override per profil.
    /// Jeśli ustawiony, launcher nakłada wartości z wybranego profilu.
    #[serde(default)]
    pub profiles: Option<LauncherProfiles>,

    /// Język interfejsu launchera (np. "pl", "en").
    #[serde(default = "default_language")]
    pub language: String,

    /// Czy sprawdzać wersję launchera przy starcie.
    #[serde(default = "default_true")]
    pub launcher_version_check: bool,

    /// Ścieżka katalogu klienta (względna do exe lub bezwzględna).
    #[serde(default = "default_client_dir")]
    pub client_dir: String,

    /// Ścieżka katalogu danych launchera.
    #[serde(default = "default_launcher_data_dir")]
    pub launcher_data_dir: String,

    /// Tryb deweloperski — akceptuj self-signed certy (NIE używać na produkcji!).
    #[serde(default)]
    pub dev_mode: bool,

    /// Klucz publiczny Ed25519 (hex, 64 znaki) do weryfikacji podpisu manifestu.
    /// Jeśli pusty/brak — podpis nie jest weryfikowany.
    #[serde(default)]
    pub manifest_public_key: Option<String>,
}

fn default_channel() -> String {
    "stable".to_string()
}

fn default_profile() -> String {
    "prod".to_string()
}

fn default_language() -> String {
    "pl".to_string()
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
            api_base_url: "https://127.0.0.1/apik/v1/".to_string(),
            channel: default_channel(),
            profile: default_profile(),
            profiles: None,
            language: default_language(),
            launcher_version_check: true,
            client_dir: default_client_dir(),
            launcher_data_dir: default_launcher_data_dir(),
            dev_mode: false,
            manifest_public_key: None,
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
        let mut config: Self = serde_json::from_str(&content).map_err(|e| ConfigError::Parse {
            path: path.to_path_buf(),
            source: e,
        })?;
        config.apply_profile_overrides()?;
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
        let (config, _path) = Self::discover_with_path(exe_dir)?;
        Ok(config)
    }

    /// Jak `discover()`, ale zwraca również ścieżkę pliku config.
    /// Jeśli config nie istnieje — zwracana jest domyślna ścieżka zapisu: `{exe_dir}/launcher_config.json`.
    pub fn discover_with_path(exe_dir: &Path) -> Result<(Self, PathBuf), ConfigError> {
        let mut candidates = vec![exe_dir.join("launcher_config.json")];
        if let Some(parent) = exe_dir.parent() {
            candidates.push(parent.join("launcher_config.json"));
        }

        for path in candidates {
            if path.exists() {
                let config = Self::load_from_file(&path)?;
                return Ok((config, path));
            }
        }

        // Brak configu — użyj domyślnych wartości
        tracing::warn!("Nie znaleziono launcher_config.json — używam domyślnych ustawień");
        Ok((Self::default(), exe_dir.join("launcher_config.json")))
    }

    /// Waliduje pola konfiguracji.
    pub fn validate(&self) -> Result<(), ConfigError> {
        let profile = normalize_profile_name(&self.profile);
        validate_profile_name(&profile)?;

        if self.api_base_url.trim().is_empty() {
            return Err(ConfigError::Validation(
                "api_base_url nie może być pusty".into(),
            ));
        }

        validate_channel(&self.channel).map_err(|e| ConfigError::Validation(e.to_string()))?;

        let require_https = profile != "dev";
        validate_url(&self.api_base_url, require_https)
            .map_err(|e| ConfigError::Validation(e.to_string()))?;

        if profile != "dev" && self.dev_mode {
            return Err(ConfigError::Validation(
                "dev_mode=true jest dozwolone tylko dla profilu dev".into(),
            ));
        }

        if profile == "prod" && self.channel != "stable" {
            return Err(ConfigError::Validation(format!(
                "Profil prod wymaga channel='stable', otrzymano '{}'",
                self.channel
            )));
        }

        if profile == "stage" && self.channel == "dev" {
            return Err(ConfigError::Validation(
                "Profil stage nie moze uzywac channel='dev'".into(),
            ));
        }

        if self.language.trim().is_empty() {
            return Err(ConfigError::Validation(
                "language nie może być pusty".into(),
            ));
        }
        if self.language.len() > 16 {
            return Err(ConfigError::Validation(
                "language jest za długi (max 16 znaków)".into(),
            ));
        }
        if !self
            .language
            .chars()
            .all(|c| c.is_ascii_alphanumeric() || c == '-' || c == '_')
        {
            return Err(ConfigError::Validation(
                "language może zawierać tylko [a-zA-Z0-9_-]".into(),
            ));
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

        if let Some(profiles) = &self.profiles {
            self.validate_profiles(profiles)?;
        }

        Ok(())
    }

    fn apply_profile_overrides(&mut self) -> Result<(), ConfigError> {
        if self.profile.trim().is_empty() {
            // Legacy config migration: old files had only devMode without profile.
            self.profile = if self.dev_mode {
                "dev".to_string()
            } else {
                default_profile()
            };
        }

        self.profile = normalize_profile_name(&self.profile);
        validate_profile_name(&self.profile)?;

        let Some(profiles) = &self.profiles else {
            return Ok(());
        };

        let profile_cfg = match self.profile.as_str() {
            "dev" => profiles.dev.as_ref(),
            "stage" => profiles.stage.as_ref(),
            "prod" => profiles.prod.as_ref(),
            _ => None,
        }
        .ok_or_else(|| {
            ConfigError::Validation(format!(
                "Brak konfiguracji profiles.{} dla wybranego profilu",
                self.profile
            ))
        })?;

        self.api_base_url = profile_cfg.api_base_url.clone();

        if let Some(channel) = &profile_cfg.channel {
            self.channel = channel.clone();
        }

        if let Some(dev_mode) = profile_cfg.dev_mode {
            self.dev_mode = dev_mode;
        }

        if let Some(launcher_version_check) = profile_cfg.launcher_version_check {
            self.launcher_version_check = launcher_version_check;
        }

        if profile_cfg.manifest_public_key.is_some() {
            self.manifest_public_key = profile_cfg.manifest_public_key.clone();
        }

        Ok(())
    }

    fn validate_profiles(&self, profiles: &LauncherProfiles) -> Result<(), ConfigError> {
        let dev = profiles
            .dev
            .as_ref()
            .ok_or_else(|| ConfigError::Validation("profiles.dev jest wymagany".into()))?;
        let stage = profiles
            .stage
            .as_ref()
            .ok_or_else(|| ConfigError::Validation("profiles.stage jest wymagany".into()))?;
        let prod = profiles
            .prod
            .as_ref()
            .ok_or_else(|| ConfigError::Validation("profiles.prod jest wymagany".into()))?;

        validate_profile_url("dev", &dev.api_base_url, false)?;
        validate_profile_url("stage", &stage.api_base_url, true)?;
        validate_profile_url("prod", &prod.api_base_url, true)?;

        if let Some(channel) = &dev.channel {
            validate_channel(channel).map_err(|e| ConfigError::Validation(e.to_string()))?;
        }
        if let Some(channel) = &stage.channel {
            validate_channel(channel).map_err(|e| ConfigError::Validation(e.to_string()))?;
            if channel == "dev" {
                return Err(ConfigError::Validation(
                    "profiles.stage.channel nie moze byc 'dev'".into(),
                ));
            }
        }
        if let Some(channel) = &prod.channel {
            if channel != "stable" {
                return Err(ConfigError::Validation(
                    "profiles.prod.channel musi byc rowny 'stable'".into(),
                ));
            }
        }

        if stage.dev_mode.unwrap_or(false) {
            return Err(ConfigError::Validation(
                "profiles.stage.devMode=true jest niedozwolone".into(),
            ));
        }
        if prod.dev_mode.unwrap_or(false) {
            return Err(ConfigError::Validation(
                "profiles.prod.devMode=true jest niedozwolone".into(),
            ));
        }

        // INS-P0-43: profile musza wskazywac ten sam kontrakt API (spojny suffix path).
        let dev_suffix = api_path_suffix(&dev.api_base_url)?;
        let stage_suffix = api_path_suffix(&stage.api_base_url)?;
        let prod_suffix = api_path_suffix(&prod.api_base_url)?;

        if dev_suffix != stage_suffix || dev_suffix != prod_suffix {
            return Err(ConfigError::Validation(format!(
                "Niespojny path endpointow profilowych (dev='{}', stage='{}', prod='{}')",
                dev_suffix, stage_suffix, prod_suffix
            )));
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

fn normalize_profile_name(profile: &str) -> String {
    profile.trim().to_ascii_lowercase()
}

fn validate_profile_name(profile: &str) -> Result<(), ConfigError> {
    if !["dev", "stage", "prod"].contains(&profile) {
        return Err(ConfigError::Validation(format!(
            "Nieprawidlowy profil: '{}' (dozwolone: dev, stage, prod)",
            profile
        )));
    }
    Ok(())
}

fn validate_profile_url(
    profile_name: &str,
    url: &str,
    require_https: bool,
) -> Result<(), ConfigError> {
    validate_url(url, require_https)
        .map_err(|e| ConfigError::Validation(format!("profiles.{}.apiBaseUrl: {}", profile_name, e)))
}

fn api_path_suffix(url: &str) -> Result<String, ConfigError> {
    let (_scheme, rest) = url
        .split_once("://")
        .ok_or_else(|| ConfigError::Validation(format!("Nieprawidlowy URL: {}", url)))?;
    let slash_idx = rest.find('/').unwrap_or(rest.len());
    let mut path = rest[slash_idx..].trim().to_string();
    if path.is_empty() {
        path = "/".to_string();
    }
    if path.len() > 1 {
        path = path.trim_end_matches('/').to_string();
    }
    Ok(path)
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
        assert_eq!(config.profile, "prod");
        assert_eq!(config.language, "pl");
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
        assert_eq!(config.profile, parsed.profile);
    }

    #[test]
    fn test_config_minimal_json() {
        let json = r#"{"apiBaseUrl": "https://api.example.com/"}"#;
        let config: LauncherConfig = serde_json::from_str(json).unwrap();
        assert_eq!(config.api_base_url, "https://api.example.com/");
        assert_eq!(config.channel, "stable");
        assert_eq!(config.profile, "prod");
        assert_eq!(config.language, "pl");
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
            channel: "hacked".to_string(),
            ..LauncherConfig::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_config_validation_empty_language() {
        let config = LauncherConfig {
            language: " ".to_string(),
            ..LauncherConfig::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_profile_stage_forbids_dev_mode() {
        let config = LauncherConfig {
            profile: "stage".to_string(),
            dev_mode: true,
            ..Default::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_profile_prod_requires_stable_channel() {
        let config = LauncherConfig {
            profile: "prod".to_string(),
            channel: "test".to_string(),
            ..Default::default()
        };
        assert!(config.validate().is_err());
    }

    #[test]
    fn test_apply_profile_overrides() {
        let mut config = LauncherConfig {
            api_base_url: "https://default.example/apik/v1".to_string(),
            profile: "dev".to_string(),
            profiles: Some(LauncherProfiles {
                dev: Some(LauncherProfileConfig {
                    api_base_url: "http://localhost:8080/apik/v1".to_string(),
                    channel: Some("dev".to_string()),
                    dev_mode: Some(true),
                    launcher_version_check: None,
                    manifest_public_key: None,
                }),
                stage: Some(LauncherProfileConfig {
                    api_base_url: "https://stage.example/apik/v1".to_string(),
                    channel: Some("test".to_string()),
                    dev_mode: Some(false),
                    launcher_version_check: None,
                    manifest_public_key: None,
                }),
                prod: Some(LauncherProfileConfig {
                    api_base_url: "https://prod.example/apik/v1".to_string(),
                    channel: Some("stable".to_string()),
                    dev_mode: Some(false),
                    launcher_version_check: None,
                    manifest_public_key: None,
                }),
            }),
            ..Default::default()
        };

        config.apply_profile_overrides().unwrap();
        assert_eq!(config.api_base_url, "http://localhost:8080/apik/v1");
        assert_eq!(config.channel, "dev");
        assert!(config.dev_mode);
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
