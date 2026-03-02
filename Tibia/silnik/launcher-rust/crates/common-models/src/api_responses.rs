//! Typy odpowiedzi z API (launcher-version, launcher-token).

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
