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
// account-sync-token.php request/response (K12/K20)
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncTokenRequest {
    #[serde(rename = "type")]
    pub request_type: String,
    pub session_key: String,
    pub source: String,
    pub target: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncTokenResponse {
    pub ok: bool,
    pub sync_token: String,
    pub source: String,
    pub target: String,
    pub expires_at: u64,

    #[serde(default)]
    pub consume_url: Option<String>,

    /// SEC-P2-001: PKCE-like verifier — passed via URL fragment hash, validated on consumption.
    #[serde(default)]
    pub verifier: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncConsumeResponse {
    pub ok: bool,
    pub sync: AccountSyncConsumeMeta,
    pub session: AccountSyncConsumeSession,
    pub account: AccountSyncConsumeAccount,

    #[serde(default)]
    pub counts: Option<serde_json::Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncConsumeMeta {
    pub source: String,
    pub target: String,
    pub consumed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncConsumeSession {
    pub session_key: String,
    pub account_id: u64,
    pub game_mode: String,
    pub expires_at: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct AccountSyncConsumeAccount {
    pub id: u64,
    pub name: String,
    pub email: String,
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
    #[serde(default)]
    pub brand: Option<String>,
    #[serde(default)]
    pub channel: Option<String>,
    #[serde(default)]
    pub version: Option<String>,
    pub artifacts: Vec<InstallerArtifact>,

    #[serde(default)]
    pub generated_at_utc: Option<String>,
}

/// Pojedynczy artefakt instalatora w katalogu.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstallerArtifact {
    /// Identyfikator artefaktu (np. "launcher-main-win", "client-player-win").
    #[serde(default)]
    pub id: Option<String>,

    /// Nazwa wyświetlana.
    #[serde(default)]
    pub name: Option<String>,

    /// Platforma: "windows", "linux", "android".
    #[serde(default)]
    pub platform: Option<String>,

    /// Architektura: "x86_64", "arm64".
    #[serde(default)]
    pub arch: Option<String>,

    /// Nazwa pliku instalatora.
    #[serde(default)]
    pub filename: Option<String>,

    /// URL do pobrania.
    #[serde(default)]
    pub url: Option<String>,

    /// Hash SHA-256 (hex, 64 znaki).
    #[serde(default)]
    pub sha256: Option<String>,

    /// Rozmiar w bajtach.
    #[serde(default)]
    pub size: Option<u64>,

    /// Typ artefaktu: "launcher", "bootstrap", "installer", "client".
    #[serde(rename = "type")]
    #[serde(default)]
    pub artifact_type: Option<String>,

    /// Profil klienta: "player", "staff", "dev" (tylko dla type=client).
    #[serde(default)]
    pub client_profile: Option<String>,

    /// Kanał: "stable", "beta", "dev".
    #[serde(default)]
    pub channel: Option<String>,

    /// Wersja artefaktu.
    #[serde(default)]
    pub version: Option<String>,

    /// Minimalna wymagana wersja (dla launcher).
    #[serde(default)]
    pub min_version: Option<String>,

    /// URL manifestu klienta (dla type=client — launcher pobiera listę plików).
    #[serde(default)]
    pub manifest_url: Option<String>,

    /// Data wydania.
    #[serde(default)]
    pub release_date: Option<String>,

    /// Notatki wydania.
    #[serde(default)]
    pub notes: Option<String>,

    /// Fallback URL.
    #[serde(default)]
    pub fallback_url: Option<String>,

    /// Opcjonalny podpis .sig (Etap 5: hardening).
    #[serde(default)]
    pub signature: Option<String>,

    /// Opcjonalna minimalna wersja OS.
    #[serde(default)]
    pub min_os_version: Option<String>,
}

// ─────────────────────────────────────────────
// language-packs.php response (Faza 9.4)
// ─────────────────────────────────────────────

/// Odpowiedź z endpointu `language-packs.php`.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LanguagePacksResponse {
    pub available_packs: Vec<LanguagePackInfo>,
}

/// Metadane pojedynczej paczki językowej.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LanguagePackInfo {
    /// Locale paczki (`en`, `pl`, `de`, `ar`, ...).
    pub locale: String,

    /// Wersja paczki.
    pub version: String,

    /// Czy paczka jest wbudowana w launcher.
    #[serde(default)]
    pub bundled: bool,

    /// Nazwa wyświetlana (opcjonalnie).
    #[serde(default)]
    pub display_name: Option<String>,

    /// Nazwa natywna (opcjonalnie).
    #[serde(default)]
    pub native_name: Option<String>,

    /// Emoji flagi (opcjonalnie).
    #[serde(default)]
    pub flag: Option<String>,

    /// Tier paczki (0..5) — opcjonalny.
    #[serde(default)]
    pub tier: Option<u8>,

    /// URL pobrania (wymagany dla `bundled=false`).
    #[serde(default)]
    pub url: Option<String>,

    /// Hash SHA-256 (wymagany dla `bundled=false`).
    #[serde(default)]
    pub sha256: Option<String>,

    /// Rozmiar w bajtach (wymagany dla `bundled=false`).
    #[serde(default)]
    pub size: Option<u64>,

    /// Dodatkowe wymagane fonty (opcjonalnie).
    #[serde(default)]
    pub requires_fonts: Vec<String>,
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

// ─────────────────────────────────────────────
// Error Reporting (Faza 8)
// ─────────────────────────────────────────────

/// Raport o błędzie wysyłany do POST /error-report.php.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorReportRequest {
    #[serde(rename = "errorCode")]
    pub error_code: String,
    pub message: String,
    #[serde(rename = "launcherVersion")]
    pub launcher_version: String,
    pub os: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub context: Option<serde_json::Value>,
}

/// Odpowiedź z POST /error-report.php.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorReportResponse {
    pub status: String,
    pub id: Option<String>,
}
