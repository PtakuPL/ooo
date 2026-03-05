//! Modele font-packów i metadanych Unicode dla launchera.

use serde::{Deserialize, Serialize};

/// Metadane paczki fontów pobieranej przez launcher.
///
/// Przykład użycia:
/// - locale: `ar`
/// - script: `arabic`
/// - version: `1.0.0`
/// - url: `https://cdn.example.com/fonts/ar-1.0.0.zip`
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct FontPackInfo {
    /// Locale, dla którego paczka jest rekomendowana (`ar`, `he`, `fa`, `zh`, ...).
    pub locale: String,
    /// Nazwa skryptu (`arabic`, `hebrew`, `cjk`, `devanagari`, ...).
    pub script: String,
    /// Wersja paczki.
    pub version: String,
    /// URL pobrania paczki.
    pub url: String,
    /// Oczekiwany hash SHA-256 (hex, 64 znaki).
    pub sha256: String,
    /// Rozmiar paczki w bajtach.
    pub size: u64,
    /// Czy paczka jest już bundlowana z launcherem.
    #[serde(default)]
    pub bundled: bool,
}

impl FontPackInfo {
    /// Walidacja podstawowa metadanych paczki fontów.
    pub fn validate(&self) -> Result<(), String> {
        if self.locale.trim().is_empty() {
            return Err("locale nie może być pusty".to_string());
        }
        if self.script.trim().is_empty() {
            return Err("script nie może być pusty".to_string());
        }
        if self.version.trim().is_empty() {
            return Err("version nie może być pusta".to_string());
        }
        if self.url.trim().is_empty() {
            return Err("url nie może być pusty".to_string());
        }
        if !self.url.starts_with("https://") {
            return Err("url font-packa musi używać HTTPS".to_string());
        }
        if self.sha256.len() != 64 || !self.sha256.chars().all(|c| c.is_ascii_hexdigit()) {
            return Err("sha256 musi być 64-znakowym hex".to_string());
        }
        if self.size == 0 {
            return Err("size musi być > 0".to_string());
        }
        Ok(())
    }

    /// Klucz cache dla lokalnego indeksu zainstalowanych paczek.
    pub fn cache_key(&self) -> String {
        format!("{}:{}:{}", self.locale, self.script, self.version)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> FontPackInfo {
        FontPackInfo {
            locale: "ar".into(),
            script: "arabic".into(),
            version: "1.0.0".into(),
            url: "https://cdn.example.com/fonts/ar-1.0.0.zip".into(),
            sha256: "a".repeat(64),
            size: 1024,
            bundled: false,
        }
    }

    #[test]
    fn test_font_pack_info_validate_ok() {
        let info = sample();
        assert!(info.validate().is_ok());
    }

    #[test]
    fn test_font_pack_info_validate_bad_sha() {
        let mut info = sample();
        info.sha256 = "xyz".into();
        assert!(info.validate().is_err());
    }

    #[test]
    fn test_font_pack_info_validate_non_https_url() {
        let mut info = sample();
        info.url = "http://cdn.example.com/font.zip".into();
        assert!(info.validate().is_err());
    }

    #[test]
    fn test_font_pack_info_cache_key() {
        let info = sample();
        assert_eq!(info.cache_key(), "ar:arabic:1.0.0");
    }
}
