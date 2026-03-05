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

    /// SHA-256 of the launcher binary (hex). Optional for backward compat.
    #[serde(default)]
    pub sha256: Option<String>,

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

    /// Nonce z /challenge.php (LR-052, opcjonalny dla backward compat).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub nonce: Option<String>,

    /// SHA-256(nonce + ":" + filesHash) — challenge response.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub challenge_response: Option<String>,
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

// ─────────────────────────────────────────────
// challenge.php response (LR-052)
// ─────────────────────────────────────────────

/// Odpowiedź z GET /challenge.php — nonce do challenge-response flow.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ChallengeResponse {
    /// Jednorazowy nonce (hex string, min 32 znaków).
    pub nonce: String,

    /// Czas ważności nonce w sekundach.
    pub expires_in_seconds: u32,

    /// Data wydania nonce (ISO-8601 UTC).
    #[serde(default)]
    pub issued_at_utc: Option<String>,
}

// ─────────────────────────────────────────────
// server-status.php response
// ─────────────────────────────────────────────

/// Odpowiedź z GET /server-status.php — lista serwerów z ich statusem.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerStatusResponse {
    pub ts: u64,
    pub servers: Vec<GameServerInfo>,
}

/// Informacja o pojedynczym serwerze gry.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GameServerInfo {
    pub id: String,
    pub name: String,
    #[serde(rename = "type")]
    pub server_type: String,
    pub status: String,
    pub players: Option<u32>,
    pub ping: Option<u32>,
    pub host: String,
    pub port: u16,
}
