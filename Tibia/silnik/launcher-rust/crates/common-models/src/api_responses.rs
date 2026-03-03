//! Typy odpowiedzi z API (launcher-version, launcher-token, installer-catalog).

use serde::{Deserialize, Serialize};

// ─────────────────────────────────────────────
// launcher-version.php response
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LauncherVersionResponse {
    pub version: String,
    pub min_version: String,
    pub required: bool,
    pub url: String,
    pub sha256: String,

    #[serde(default)]
    pub release_date: Option<String>,

    #[serde(default)]
    pub notes: Option<String>,
}

// ─────────────────────────────────────────────
// launcher-token.php response
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LaunchTokenResponse {
    pub token: String,
    pub expires_in_seconds: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LaunchTokenErrorResponse {
    pub error: String,
    pub message: String,
}

// ─────────────────────────────────────────────
// launcher-token.php request
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LaunchTokenRequest {
    pub launcher_version: String,
    pub files_hash: String,
    pub channel: String,
    pub manifest_version: String,
}

// ─────────────────────────────────────────────
// installer-catalog.php response (LR-043)
// ─────────────────────────────────────────────

/// Odpowiedź z endpoint `installer-catalog.php`.
/// Zawiera listę artefaktów (instalatorów) dla danego kanału.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstallerCatalogResponse {
    pub channel: String,
    pub version: String,
    pub artifacts: Vec<InstallerArtifact>,

    #[serde(default)]
    pub generated_at_utc: Option<String>,
}

/// Pojedynczy artefakt instalatora w katalogu.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstallerArtifact {
    /// Platforma: "windows", "linux", "android".
    pub platform: String,

    /// Architektura: "x86_64", "arm64".
    pub arch: String,

    /// Nazwa pliku instalatora.
    pub filename: String,

    /// URL do pobrania.
    pub url: String,

    /// Hash SHA-256 (hex, 64 znaki).
    pub sha256: String,

    /// Rozmiar w bajtach.
    pub size: u64,

    /// Typ artefaktu: "installer", "portable", "update".
    #[serde(rename = "type")]
    pub artifact_type: String,

    /// Opcjonalny podpis .sig (Etap 5: hardening).
    #[serde(default)]
    pub signature: Option<String>,

    /// Opcjonalna minimalna wersja OS.
    #[serde(default)]
    pub min_os_version: Option<String>,
}
