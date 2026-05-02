//! Klient API launchera — pełna implementacja (LR-013, LR-015, LR-023).
//!
//! Obsługuje:
//! - `launcher-version.php` (sprawdzenie wersji launchera)
//! - `update.php` (pobranie manifestu klienta)
//! - `launcher-token.php` (pobranie launch-tokena)
//! - pobieranie plików z URL (download z retry)

use common_models::api_responses::{
    AccountSyncConsumeResponse, AccountSyncTokenRequest, AccountSyncTokenResponse,
    ChallengeResponse, ErrorReportRequest, ErrorReportResponse, InstallerCatalogResponse,
    LanguagePacksResponse, LaunchTokenErrorResponse, LaunchTokenRequest, LaunchTokenResponse,
    LauncherVersionResponse,
};
use common_models::manifest::{parse_manifest_compat, ManifestParseError, NormalizedManifest};
use std::net::{IpAddr, ToSocketAddrs};

const CHALLENGE_MAX_TTL_SECONDS: u32 = 30;
const CHALLENGE_MIN_NONCE_LEN: usize = 32;

/// Konfiguracja klienta API.
#[derive(Debug, Clone)]
pub struct ApiClientConfig {
    pub base_url: String,
    pub timeout_seconds: u64,
    pub max_retries: u32,
    pub user_agent: String,
    /// Accept self-signed certs (dev only!).
    pub dev_mode: bool,
}

impl Default for ApiClientConfig {
    fn default() -> Self {
        Self {
            base_url: String::new(),
            timeout_seconds: 30,
            max_retries: 3,
            user_agent: "TwojaGra-Launcher/1.0.0".to_string(),
            dev_mode: false,
        }
    }
}

/// Błędy klienta API.
#[derive(Debug, thiserror::Error)]
pub enum ApiError {
    #[error("HTTP error: {0}")]
    Http(#[from] reqwest::Error),

    #[error("HTTP status {status}: {body}")]
    HttpStatus { status: u16, body: String },

    #[error("JSON parse error: {0}")]
    JsonParse(#[from] serde_json::Error),

    #[error("Manifest parse error: {0}")]
    ManifestParse(#[from] ManifestParseError),

    #[error("Token rejected: {error} — {message}")]
    TokenRejected { error: String, message: String },

    #[error("Rate limited (HTTP 429)")]
    RateLimited,

    #[error("TLS required but base_url is not HTTPS")]
    TlsRequired,

    #[error("Invalid URL: {0}")]
    InvalidUrl(String),

    #[error("Max retries ({0}) exceeded")]
    MaxRetriesExceeded(u32),

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
}

/// Wynik pobrania manifestu z surowym JSON-em i opcjonalnym podpisem.
///
/// Używane przez `fetch_manifest_with_signature()` do weryfikacji podpisów (LR-053).
#[derive(Debug, Clone)]
pub struct ManifestFetchResult {
    pub manifest: NormalizedManifest,
    pub raw_json: String,
    pub signature_hex: Option<String>,
}

/// Klient API launchera.
pub struct ApiClient {
    pub config: ApiClientConfig,
    http: reqwest::Client,
}

impl ApiClient {
    /// Tworzy nowego klienta API z podaną konfiguracją.
    pub fn new(config: ApiClientConfig) -> Result<Self, ApiError> {
        let loopback_origin = is_loopback_origin(&config.base_url);

        // HTTPS is required outside explicit dev mode.
        // Loopback HTTP/HTTPS (127.0.0.1/localhost/[::1] or host resolving only to loopback)
        // is always allowed for local tests.
        if !config.base_url.is_empty()
            && !config.base_url.starts_with("https://")
            && !loopback_origin
            && !config.dev_mode
        {
            return Err(ApiError::TlsRequired);
        }

        if !config.base_url.is_empty() && !config.base_url.starts_with("https://") {
            tracing::warn!(
                "Base URL nie używa HTTPS: {} — dozwolone tylko w dev_mode",
                config.base_url
            );
        }

        let allow_invalid_certs = config.dev_mode || loopback_origin;
        if loopback_origin && !config.dev_mode {
            tracing::warn!(
                "Base URL rozwiazuje sie do loopbacka — wlaczam akceptacje lokalnego certyfikatu: {}",
                config.base_url
            );
        }

        let http = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(config.timeout_seconds))
            .user_agent(&config.user_agent)
            .danger_accept_invalid_certs(allow_invalid_certs)
            .build()?;

        Ok(Self { config, http })
    }

    /// Buduje pełny URL z base_url + endpoint.
    fn url(&self, endpoint: &str) -> String {
        let base = self.config.base_url.trim_end_matches('/');
        format!("{}/{}", base, endpoint.trim_start_matches('/'))
    }

    fn resolve_download_url(&self, url: &str) -> Result<String, ApiError> {
        let trimmed = url.trim();
        if trimmed.is_empty() {
            return Err(ApiError::InvalidUrl("empty download URL".to_string()));
        }

        let resolved = match reqwest::Url::parse(trimmed) {
            Ok(parsed) => parsed,
            Err(_) => {
                if self.config.base_url.trim().is_empty() {
                    return Err(ApiError::InvalidUrl(trimmed.to_string()));
                }
                let base = reqwest::Url::parse(&format!(
                    "{}/",
                    self.config.base_url.trim_end_matches('/')
                ))
                .map_err(|e| ApiError::InvalidUrl(format!("{} ({e})", self.config.base_url)))?;
                base.join(trimmed)
                    .map_err(|e| ApiError::InvalidUrl(format!("{trimmed} ({e})")))?
            }
        };

        let resolved_string = resolved.to_string();
        if resolved.scheme() != "https"
            && !is_loopback_origin(&resolved_string)
            && !self.config.dev_mode
        {
            return Err(ApiError::TlsRequired);
        }

        Ok(resolved_string)
    }

    // ─────────────────────────────────────────
    // LR-013: launcher-version.php
    // ─────────────────────────────────────────

    /// Sprawdza najnowszą wersję launchera na serwerze.
    pub async fn check_launcher_version(&self) -> Result<LauncherVersionResponse, ApiError> {
        let platform = if cfg!(target_os = "windows") {
            "windows"
        } else if cfg!(target_os = "linux") {
            "linux"
        } else {
            "unknown"
        };
        let arch = if cfg!(target_arch = "x86_64") {
            "x86_64"
        } else if cfg!(target_arch = "aarch64") {
            "arm64"
        } else {
            "unknown"
        };
        let url = self.url(&format!(
            "launcher-version.php?platform={}&arch={}",
            platform, arch
        ));
        tracing::info!("Sprawdzam wersję launchera: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let version: LauncherVersionResponse = resp.json().await?;
        Ok(version)
    }

    // ─────────────────────────────────────────
    // LR-015: update.php (manifest fetch + parse)
    // ─────────────────────────────────────────

    /// Pobiera manifest klienta z API i parsuje go (v1/v2 compat).
    pub async fn fetch_manifest(&self, channel: &str) -> Result<NormalizedManifest, ApiError> {
        let url = self.url(&format!("update.php?channel={}", channel));
        tracing::info!("Pobieram manifest: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let json_text = resp.text().await?;
        let manifest = parse_manifest_compat(&json_text)?;
        Ok(manifest)
    }

    /// Pobiera manifest + surowy JSON + opcjonalny podpis z nagłówka `X-Manifest-Signature`.
    ///
    /// Używane przez flow aktualizacji do weryfikacji podpisu (LR-053).
    pub async fn fetch_manifest_with_signature(
        &self,
        channel: &str,
    ) -> Result<ManifestFetchResult, ApiError> {
        let url = self.url(&format!("update.php?channel={}", channel));
        tracing::info!("Pobieram manifest (z weryfikacją podpisu): {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        // Wyciągnij podpis z nagłówka zanim konsumujemy body
        let signature_hex = resp
            .headers()
            .get("X-Manifest-Signature")
            .and_then(|v| v.to_str().ok())
            .map(|s| s.to_string());

        let raw_json = resp.text().await?;
        let manifest = parse_manifest_compat(&raw_json)?;

        Ok(ManifestFetchResult {
            manifest,
            raw_json,
            signature_hex,
        })
    }

    // ─────────────────────────────────────────
    // LR-023: launcher-token.php
    // ─────────────────────────────────────────

    /// Pobiera launch-token z API.
    pub async fn request_launch_token(
        &self,
        request: &LaunchTokenRequest,
    ) -> Result<LaunchTokenResponse, ApiError> {
        let url = self.url("launcher-token.php");
        tracing::info!(
            "Pobieram launch-token: {} (manifest_version={})",
            url,
            request.manifest_version
        );

        let resp = self.http.post(&url).json(request).send().await?;

        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();

            // Sprawdź czy to strukturalny błąd tokena
            if let Ok(err) = serde_json::from_str::<LaunchTokenErrorResponse>(&body) {
                return Err(ApiError::TokenRejected {
                    error: err.error,
                    message: err.message,
                });
            }

            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let token_resp: LaunchTokenResponse = resp.json().await?;
        Ok(token_resp)
    }

    /// Issue one-time WWW sync token from launcher session.
    pub async fn request_account_sync_token(
        &self,
        session_key: &str,
        source: &str,
        target: &str,
    ) -> Result<AccountSyncTokenResponse, ApiError> {
        let url = self.url("account-sync-token.php");
        tracing::info!(
            "Pobieram account sync token: {} ({} -> {})",
            url,
            source,
            target
        );

        let request = AccountSyncTokenRequest {
            request_type: "account_sync_token".to_string(),
            session_key: session_key.to_string(),
            source: source.to_string(),
            target: target.to_string(),
        };

        let resp = self.http.post(&url).json(&request).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let sync_resp: AccountSyncTokenResponse = resp.json().await?;
        if !sync_resp.ok {
            return Err(ApiError::HttpStatus {
                status: 200,
                body: "Account sync token response has ok=false".to_string(),
            });
        }
        if sync_resp.sync_token.trim().is_empty() {
            return Err(ApiError::HttpStatus {
                status: 200,
                body: "Account sync token is empty".to_string(),
            });
        }

        Ok(sync_resp)
    }

    /// Consume one-time WWW->launcher sync token and issue launcher session.
    pub async fn consume_account_sync_token(
        &self,
        sync_token: &str,
        source: &str,
        target: &str,
        verifier: Option<&str>,
    ) -> Result<AccountSyncConsumeResponse, ApiError> {
        let url = self.url("account-sync-consume.php");
        tracing::info!(
            "Konsumuje account sync token: {} ({} -> {})",
            url,
            source,
            target
        );

        let mut payload = serde_json::json!({
            "type": "account_sync_consume",
            "syncToken": sync_token,
            "source": source,
            "target": target,
        });
        if let Some(v) = verifier {
            payload["verifier"] = serde_json::Value::String(v.to_string());
        }

        let resp = self.http.post(&url).json(&payload).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let body = resp.text().await?;
        let value: serde_json::Value = serde_json::from_str(&body)?;
        if let Some(error_message) = value.get("message").and_then(|v| v.as_str()) {
            let error_code = value
                .get("error")
                .and_then(|v| v.as_str())
                .unwrap_or("account_sync_consume_failed");
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: format!("{error_code}: {error_message}"),
            });
        }

        let sync_resp: AccountSyncConsumeResponse = serde_json::from_value(value)?;
        if !sync_resp.ok {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: "Account sync consume response has ok=false".to_string(),
            });
        }
        if sync_resp.session.session_key.trim().is_empty() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: "Account sync consume sessionKey is empty".to_string(),
            });
        }

        Ok(sync_resp)
    }

    /// Fetch account context (worlds/characters/session) for existing launcher session.
    pub async fn fetch_account_context(
        &self,
        session_key: &str,
    ) -> Result<serde_json::Value, ApiError> {
        let url = self.url("account-context.php");
        tracing::info!("Pobieram account context: {}", url);

        let payload = serde_json::json!({
            "type": "account_context",
            "sessionKey": session_key,
        });

        let resp = self.http.post(&url).json(&payload).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        let body = resp.text().await.unwrap_or_default();
        let value: serde_json::Value = serde_json::from_str(&body)?;

        // account-context.php moze zwracac bledy jako JSON z errorMessage.
        if let Some(error_message) = value.get("errorMessage").and_then(|v| v.as_str()) {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: error_message.to_string(),
            });
        }

        if !status.is_success() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        Ok(value)
    }

    /// Switch active launcher account profile (`gameMode`) for existing session.
    pub async fn switch_account_profile(
        &self,
        session_key: &str,
        game_mode: &str,
    ) -> Result<serde_json::Value, ApiError> {
        let url = self.url("account-profile-switch.php");
        tracing::info!("Przelaczam account profile: {} -> {}", url, game_mode);

        let payload = serde_json::json!({
            "type": "account_profile_switch",
            "sessionKey": session_key,
            "gameMode": game_mode,
        });

        let resp = self.http.post(&url).json(&payload).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        let body = resp.text().await.unwrap_or_default();
        let value: serde_json::Value = serde_json::from_str(&body)?;

        if let Some(error_message) = value.get("errorMessage").and_then(|v| v.as_str()) {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: error_message.to_string(),
            });
        }

        if !status.is_success() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        Ok(value)
    }

    /// LK-012: Fetch game profiles (modes, servers, features) — public endpoint, no auth.
    pub async fn fetch_game_profiles(&self) -> Result<serde_json::Value, ApiError> {
        let url = self.url("game-profiles.php");
        tracing::info!("Pobieram game profiles: {}", url);

        let resp = self.http.get(&url).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        let body = resp.text().await.unwrap_or_default();

        if !status.is_success() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let value: serde_json::Value = serde_json::from_str(&body)?;

        if let Some(error_message) = value.get("errorMessage").and_then(|v| v.as_str()) {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: error_message.to_string(),
            });
        }

        Ok(value)
    }

    /// Login konta launchera (email+password) przez `login.php`.
    /// Zwraca surowy JSON odpowiedzi endpointu.
    pub async fn login_account(
        &self,
        email: &str,
        password: &str,
        game_mode: &str,
        launch_token: Option<&str>,
        fresh_install: bool,
    ) -> Result<serde_json::Value, ApiError> {
        let url = self.url("login.php");
        tracing::info!("Logowanie konta launchera: {}", url);

        let mut payload = serde_json::json!({
            "type": "login",
            "email": email,
            "password": password,
            "gameMode": game_mode
        });

        if let Some(token) = launch_token {
            if !token.trim().is_empty() {
                payload["launchToken"] = serde_json::Value::String(token.to_string());
            }
        }

        if fresh_install {
            payload["freshInstall"] = serde_json::Value::Bool(true);
        }

        let resp = self.http.post(&url).json(&payload).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        let body = resp.text().await.unwrap_or_default();
        let value: serde_json::Value = serde_json::from_str(&body)?;

        // login.php historycznie zwraca błędy jako 200 + {errorCode, errorMessage, lchCode?}
        if let Some(error_message) = value.get("errorMessage").and_then(|v| v.as_str()) {
            let mut msg = error_message.to_string();
            if let Some(lch) = value.get("lchCode").and_then(|v| v.as_str()) {
                msg = format!("{lch}: {msg}");
            }
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: msg,
            });
        }

        if !status.is_success() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        Ok(value)
    }

    /// Rejestracja konta launchera przez `register-account.php`.
    /// Zwraca surowy JSON odpowiedzi endpointu.
    pub async fn register_account(
        &self,
        account_name: &str,
        email: &str,
        password: &str,
        password_confirm: &str,
    ) -> Result<serde_json::Value, ApiError> {
        let url = self.url("register-account.php");
        tracing::info!("Rejestracja konta launchera: {}", url);

        // Keep the same action as WWW/RedDAXE to guarantee one shared register flow.
        let payload = serde_json::json!({
            "type": "register",
            "accountName": account_name,
            "email": email,
            "password": password,
            "passwordConfirm": password_confirm
        });

        let resp = self.http.post(&url).json(&payload).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        let body = resp.text().await.unwrap_or_default();
        let value: serde_json::Value = serde_json::from_str(&body)?;

        // register-account.php moze zwracac bledy jako JSON z errorMessage.
        if let Some(error_message) = value.get("errorMessage").and_then(|v| v.as_str()) {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body: error_message.to_string(),
            });
        }

        if !status.is_success() {
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        Ok(value)
    }

    // ─────────────────────────────────────────
    // LR-043: installer-catalog.php
    // ─────────────────────────────────────────

    /// Pobiera katalog artefaktów instalatora z API.
    pub async fn fetch_installer_catalog(
        &self,
        channel: &str,
    ) -> Result<InstallerCatalogResponse, ApiError> {
        let url = self.url(&format!("installer-catalog.php?channel={}", channel));
        tracing::info!("Pobieram katalog instalatorów: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let catalog: InstallerCatalogResponse = resp.json().await?;

        // Walidacja: artifacts nie może być pusty
        if catalog.artifacts.is_empty() {
            return Err(ApiError::HttpStatus {
                status: 200,
                body: "Catalog has no artifacts".to_string(),
            });
        }

        Ok(catalog)
    }

    // ─────────────────────────────────────────
    // Faza 9.4: language-packs.php
    // ─────────────────────────────────────────

    /// Pobiera listę dostępnych paczek językowych.
    pub async fn fetch_language_packs(&self) -> Result<LanguagePacksResponse, ApiError> {
        let url = self.url("language-packs.php");
        tracing::info!("Pobieram katalog paczek językowych: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let packs: LanguagePacksResponse = resp.json().await?;
        Ok(packs)
    }

    // ─────────────────────────────────────────
    // LR-045: client pack from installer-catalog
    // ─────────────────────────────────────────

    /// Pobiera katalog artefaktów klienta z API (type=client, opcjonalnie profile=player).
    pub async fn fetch_client_pack_catalog(
        &self,
        channel: &str,
        profile: &str,
    ) -> Result<InstallerCatalogResponse, ApiError> {
        let url = self.url(&format!(
            "installer-catalog.php?channel={}&type=client&profile={}",
            channel, profile
        ));
        tracing::info!("Pobieram katalog client pack: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let catalog: InstallerCatalogResponse = resp.json().await?;
        Ok(catalog)
    }

    // ─────────────────────────────────────────
    // LR-052: challenge.php
    // ─────────────────────────────────────────

    /// Pobiera nonce z /challenge.php do challenge-response flow.
    /// Zwraca ChallengeResponse z nonce i TTL.
    /// Jeśli API nie wspiera challenge (404), zwraca None (backward compat).
    pub async fn fetch_challenge(
        &self,
        channel: &str,
    ) -> Result<Option<ChallengeResponse>, ApiError> {
        let url = self.url(&format!("challenge.php?channel={}", channel));
        tracing::info!("Pobieram challenge nonce: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        // 404 = API nie wspiera challenge → backward compat
        if status == reqwest::StatusCode::NOT_FOUND {
            tracing::info!("Challenge endpoint nie istnieje (404) — tryb legacy");
            return Ok(None);
        }

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let challenge: ChallengeResponse = resp.json().await?;
        validate_challenge_response(&challenge)?;

        Ok(Some(challenge))
    }

    // ─────────────────────────────────────────
    // server-status.php — status serwerów gry
    // ─────────────────────────────────────────

    /// Pobiera status serwerów gry (online/offline, gracze, ping).
    pub async fn fetch_server_status(
        &self,
    ) -> Result<common_models::api_responses::ServerStatusResponse, ApiError> {
        let url = self.url("server-status.php");
        tracing::debug!("Pobieram status serwerów: {}", url);

        let resp = self.get_with_retry(&url).await?;
        let status = resp.status();

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let server_status = resp.json().await?;
        Ok(server_status)
    }

    /// Lightweight endpoint probe for health-check/preflight.
    ///
    /// Returns raw HTTP status code for the given endpoint path.
    /// Network/TLS/transport failures are returned as `ApiError`.
    pub async fn probe_endpoint_status(&self, endpoint: &str) -> Result<u16, ApiError> {
        let url = self.url(endpoint);
        let resp = self.http.get(&url).send().await?;
        Ok(resp.status().as_u16())
    }

    // ─────────────────────────────────────────
    // LR-019: Download file with retry
    // ─────────────────────────────────────────

    /// Pobiera plik z podanego URL, zwraca bajty.
    /// Obsługuje retry wg `max_retries` z konfiguracji.
    pub async fn download_file(&self, url: &str) -> Result<Vec<u8>, ApiError> {
        let resolved_url = self.resolve_download_url(url)?;
        tracing::debug!("Pobieram plik: {}", resolved_url);

        let mut last_error: Option<ApiError> = None;

        for attempt in 0..=self.config.max_retries {
            if attempt > 0 {
                let delay = std::time::Duration::from_millis(500 * 2u64.pow(attempt - 1));
                tracing::warn!(
                    "Retry {}/{} za {:?}: {}",
                    attempt,
                    self.config.max_retries,
                    delay,
                    resolved_url
                );
                tokio::time::sleep(delay).await;
            }

            match self.http.get(&resolved_url).send().await {
                Ok(resp) => {
                    let status = resp.status();
                    if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
                        last_error = Some(ApiError::RateLimited);
                        continue;
                    }
                    if !status.is_success() {
                        let body = resp.text().await.unwrap_or_default();
                        last_error = Some(ApiError::HttpStatus {
                            status: status.as_u16(),
                            body,
                        });
                        continue;
                    }

                    let bytes = resp.bytes().await?;
                    return Ok(bytes.to_vec());
                }
                Err(e) => {
                    last_error = Some(ApiError::Http(e));
                    continue;
                }
            }
        }

        match last_error {
            Some(e) => Err(e),
            None => Err(ApiError::MaxRetriesExceeded(self.config.max_retries)),
        }
    }

    // ─────────────────────────────────────────
    // Faza 8: error-report.php — raportowanie błędów
    // ─────────────────────────────────────────

    /// Wysyła raport o błędzie do API (fire-and-forget, nie blokuje UI).
    /// Zwraca Ok(()) nawet jeśli serwer odrzuci — loguje tylko ostrzeżenie.
    pub async fn report_error(
        &self,
        report: &ErrorReportRequest,
    ) -> Result<ErrorReportResponse, ApiError> {
        let url = self.url("error-report.php");
        tracing::info!(
            "Wysyłam raport o błędzie: {} (code={})",
            url,
            report.error_code
        );

        let resp = self.http.post(&url).json(report).send().await?;
        let status = resp.status();

        if status == reqwest::StatusCode::TOO_MANY_REQUESTS {
            return Err(ApiError::RateLimited);
        }

        if !status.is_success() {
            let body = resp.text().await.unwrap_or_default();
            return Err(ApiError::HttpStatus {
                status: status.as_u16(),
                body,
            });
        }

        let response: ErrorReportResponse = resp.json().await?;
        Ok(response)
    }

    /// Fire-and-forget: wysyła raport i loguje wynik, nigdy nie zwraca błędu.
    pub async fn report_error_silent(&self, report: &ErrorReportRequest) {
        match self.report_error(report).await {
            Ok(r) => tracing::debug!("Raport wysłany: id={}", r.id.unwrap_or_default()),
            Err(e) => tracing::warn!("Nie udało się wysłać raportu o błędzie: {}", e),
        }
    }

    // ─────────────────────────────────────────
    // Helper: GET z retry
    // ─────────────────────────────────────────

    /// Wykonuje GET z retry (exponential backoff).
    async fn get_with_retry(&self, url: &str) -> Result<reqwest::Response, ApiError> {
        let mut last_error: Option<reqwest::Error> = None;

        for attempt in 0..=self.config.max_retries {
            if attempt > 0 {
                let delay = std::time::Duration::from_millis(500 * 2u64.pow(attempt - 1));
                tracing::warn!(
                    "GET retry {}/{} za {:?}: {}",
                    attempt,
                    self.config.max_retries,
                    delay,
                    url
                );
                tokio::time::sleep(delay).await;
            }

            match self.http.get(url).send().await {
                Ok(resp) => return Ok(resp),
                Err(e) => {
                    last_error = Some(e);
                    continue;
                }
            }
        }

        match last_error {
            Some(e) => Err(ApiError::Http(e)),
            None => Err(ApiError::MaxRetriesExceeded(self.config.max_retries)),
        }
    }
}

fn validate_challenge_response(challenge: &ChallengeResponse) -> Result<(), ApiError> {
    let nonce = challenge.nonce.trim();
    if nonce.is_empty() {
        return Err(ApiError::HttpStatus {
            status: 200,
            body: "Challenge nonce is empty".to_string(),
        });
    }

    if nonce.len() < CHALLENGE_MIN_NONCE_LEN {
        return Err(ApiError::HttpStatus {
            status: 200,
            body: format!(
                "Challenge nonce too short: got {}, expected at least {}",
                nonce.len(),
                CHALLENGE_MIN_NONCE_LEN
            ),
        });
    }

    if !nonce.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(ApiError::HttpStatus {
            status: 200,
            body: "Challenge nonce is not hex".to_string(),
        });
    }

    if challenge.expires_in_seconds == 0 {
        return Err(ApiError::HttpStatus {
            status: 200,
            body: "Challenge TTL is zero".to_string(),
        });
    }

    if challenge.expires_in_seconds > CHALLENGE_MAX_TTL_SECONDS {
        return Err(ApiError::HttpStatus {
            status: 200,
            body: format!(
                "Challenge TTL too high: {}s (max {}s)",
                challenge.expires_in_seconds, CHALLENGE_MAX_TTL_SECONDS
            ),
        });
    }

    Ok(())
}

fn is_literal_loopback_host(host: &str) -> bool {
    let normalized = host.trim_matches(['[', ']']);

    if normalized.eq_ignore_ascii_case("localhost") {
        return true;
    }

    match normalized.parse::<IpAddr>() {
        Ok(ip) => ip.is_loopback(),
        Err(_) => false,
    }
}

/// Sprawdza czy origin URL jest lokalnym loopbackiem:
/// - bezposrednio po hoscie (`127.0.0.1`, `localhost`, `[::1]`)
/// - albo po DNS, jesli host rozwiazuje sie wyłącznie do adresow loopback.
fn is_loopback_origin(url: &str) -> bool {
    let parsed = match reqwest::Url::parse(url) {
        Ok(parsed) => parsed,
        Err(_) => return false,
    };

    let host = match parsed.host_str() {
        Some(host) => host,
        None => return false,
    };

    if is_literal_loopback_host(host) {
        return true;
    }

    let port = match parsed.port_or_known_default() {
        Some(port) => port,
        None => return false,
    };

    let addrs = match (host, port).to_socket_addrs() {
        Ok(addrs) => addrs,
        Err(_) => return false,
    };

    let mut resolved_any = false;
    for addr in addrs {
        resolved_any = true;
        if !addr.ip().is_loopback() {
            return false;
        }
    }

    resolved_any
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::{json, Value};
    use std::io::{Read, Write};
    use std::net::{TcpListener, TcpStream};
    use std::sync::{Arc, Mutex};
    use std::thread;
    use std::time::Duration;

    #[derive(Debug, Clone)]
    struct CapturedHttpRequest {
        request_line: String,
        headers: Vec<String>,
        body: String,
    }

    struct SingleRequestServer {
        base_url: String,
        captured: Arc<Mutex<Option<CapturedHttpRequest>>>,
        handle: thread::JoinHandle<()>,
    }

    impl SingleRequestServer {
        fn start(status_code: u16, response_body: &str) -> Self {
            let listener = TcpListener::bind("127.0.0.1:0").expect("bind test server");
            let addr = listener.local_addr().expect("local addr");
            let captured = Arc::new(Mutex::new(None));
            let captured_clone = Arc::clone(&captured);
            let body = response_body.to_string();

            let handle = thread::spawn(move || {
                let (mut stream, _) = listener.accept().expect("accept");
                stream
                    .set_read_timeout(Some(Duration::from_secs(2)))
                    .expect("set timeout");

                let request = read_http_request(&mut stream).expect("read request");
                *captured_clone.lock().expect("lock captured") = Some(request);

                let reason = match status_code {
                    200 => "OK",
                    429 => "Too Many Requests",
                    500 => "Internal Server Error",
                    _ => "OK",
                };

                let response = format!(
                    "HTTP/1.1 {} {}\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                    status_code,
                    reason,
                    body.len(),
                    body
                );
                stream
                    .write_all(response.as_bytes())
                    .expect("write response");
                stream.flush().expect("flush response");
            });

            Self {
                base_url: format!("http://{}", addr),
                captured,
                handle,
            }
        }

        fn wait(self) -> CapturedHttpRequest {
            self.handle.join().expect("join server thread");
            self.captured
                .lock()
                .expect("lock captured")
                .clone()
                .expect("captured request")
        }
    }

    fn find_sequence(haystack: &[u8], needle: &[u8]) -> Option<usize> {
        haystack
            .windows(needle.len())
            .position(|window| window == needle)
    }

    fn parse_content_length(headers: &str) -> usize {
        headers
            .lines()
            .find_map(|line| {
                let (name, value) = line.split_once(':')?;
                if name.trim().eq_ignore_ascii_case("content-length") {
                    return value.trim().parse::<usize>().ok();
                }
                None
            })
            .unwrap_or(0)
    }

    fn read_http_request(stream: &mut TcpStream) -> std::io::Result<CapturedHttpRequest> {
        let mut bytes = Vec::new();
        let mut buf = [0_u8; 1024];
        let mut headers_end = None;

        while headers_end.is_none() {
            let n = stream.read(&mut buf)?;
            if n == 0 {
                break;
            }
            bytes.extend_from_slice(&buf[..n]);
            headers_end = find_sequence(&bytes, b"\r\n\r\n");
            if bytes.len() > 128 * 1024 {
                break;
            }
        }

        let headers_end = headers_end.ok_or_else(|| {
            std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "missing HTTP headers terminator",
            )
        })?;
        let headers_text = String::from_utf8_lossy(&bytes[..headers_end]).to_string();

        let mut lines = headers_text.lines();
        let request_line = lines.next().unwrap_or_default().to_string();
        let headers: Vec<String> = lines
            .filter(|line| !line.trim().is_empty())
            .map(ToString::to_string)
            .collect();

        let content_length = parse_content_length(&headers_text);
        let body_start = headers_end + 4;
        let mut body = if bytes.len() > body_start {
            bytes[body_start..].to_vec()
        } else {
            Vec::new()
        };

        while body.len() < content_length {
            let n = stream.read(&mut buf)?;
            if n == 0 {
                break;
            }
            body.extend_from_slice(&buf[..n]);
        }
        body.truncate(content_length);

        Ok(CapturedHttpRequest {
            request_line,
            headers,
            body: String::from_utf8_lossy(&body).to_string(),
        })
    }

    #[test]
    fn test_api_client_config_default() {
        let config = ApiClientConfig::default();
        assert_eq!(config.timeout_seconds, 30);
        assert_eq!(config.max_retries, 3);
        assert!(!config.user_agent.is_empty());
    }

    #[test]
    fn test_url_building() {
        let config = ApiClientConfig {
            base_url: "https://api.example.com/v1/".to_string(),
            ..Default::default()
        };
        let client = ApiClient::new(config).expect("client");
        assert_eq!(
            client.url("launcher-version.php"),
            "https://api.example.com/v1/launcher-version.php"
        );
        assert_eq!(
            client.url("/update.php?channel=stable"),
            "https://api.example.com/v1/update.php?channel=stable"
        );
    }

    #[test]
    fn test_url_building_no_trailing_slash() {
        let config = ApiClientConfig {
            base_url: "https://api.example.com/v1".to_string(),
            ..Default::default()
        };
        let client = ApiClient::new(config).expect("client");
        assert_eq!(
            client.url("launcher-version.php"),
            "https://api.example.com/v1/launcher-version.php"
        );
    }

    #[test]
    fn test_resolve_download_url_relative_paths() {
        let config = ApiClientConfig {
            base_url: "https://api.example.com/apik/v1".to_string(),
            ..Default::default()
        };
        let client = ApiClient::new(config).expect("client");

        assert_eq!(
            client
                .resolve_download_url("/files/bootstrap/a.zip")
                .unwrap(),
            "https://api.example.com/files/bootstrap/a.zip"
        );
        assert_eq!(
            client.resolve_download_url("files/stable/a.dat").unwrap(),
            "https://api.example.com/apik/v1/files/stable/a.dat"
        );
    }

    #[test]
    fn test_is_literal_loopback_host() {
        assert!(is_literal_loopback_host("127.0.0.1"));
        assert!(is_literal_loopback_host("::1"));
        assert!(is_literal_loopback_host("localhost"));
        assert!(!is_literal_loopback_host("example.com"));
    }

    #[test]
    fn test_is_loopback_origin_for_literal_loopback_urls() {
        assert!(is_loopback_origin("http://127.0.0.1:8080/apik/v1"));
        assert!(is_loopback_origin("https://localhost/apik/v1"));
        assert!(is_loopback_origin("https://[::1]/apik/v1"));
    }

    #[test]
    fn test_validate_challenge_response_ok() {
        let challenge = ChallengeResponse {
            nonce: "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4".to_string(),
            expires_in_seconds: 30,
            issued_at_utc: Some("2026-03-05T15:00:00Z".to_string()),
        };

        assert!(validate_challenge_response(&challenge).is_ok());
    }

    #[test]
    fn test_validate_challenge_response_empty_nonce() {
        let challenge = ChallengeResponse {
            nonce: String::new(),
            expires_in_seconds: 30,
            issued_at_utc: None,
        };

        assert!(matches!(
            validate_challenge_response(&challenge),
            Err(ApiError::HttpStatus { status: 200, .. })
        ));
    }

    #[test]
    fn test_validate_challenge_response_nonce_not_hex() {
        let challenge = ChallengeResponse {
            nonce: "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz".to_string(),
            expires_in_seconds: 30,
            issued_at_utc: None,
        };

        assert!(matches!(
            validate_challenge_response(&challenge),
            Err(ApiError::HttpStatus { status: 200, .. })
        ));
    }

    #[test]
    fn test_validate_challenge_response_nonce_too_short() {
        let challenge = ChallengeResponse {
            nonce: "abcd1234".to_string(),
            expires_in_seconds: 30,
            issued_at_utc: None,
        };

        assert!(matches!(
            validate_challenge_response(&challenge),
            Err(ApiError::HttpStatus { status: 200, .. })
        ));
    }

    #[test]
    fn test_validate_challenge_response_ttl_zero() {
        let challenge = ChallengeResponse {
            nonce: "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4".to_string(),
            expires_in_seconds: 0,
            issued_at_utc: None,
        };

        assert!(matches!(
            validate_challenge_response(&challenge),
            Err(ApiError::HttpStatus { status: 200, .. })
        ));
    }

    #[test]
    fn test_validate_challenge_response_ttl_too_high() {
        let challenge = ChallengeResponse {
            nonce: "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4".to_string(),
            expires_in_seconds: 31,
            issued_at_utc: None,
        };

        assert!(matches!(
            validate_challenge_response(&challenge),
            Err(ApiError::HttpStatus { status: 200, .. })
        ));
    }

    #[tokio::test]
    async fn test_error_report_sent_on_download_failure() {
        let server =
            SingleRequestServer::start(200, r#"{"status":"accepted","id":"err-download-1"}"#);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let report = ErrorReportRequest {
            error_code: "DOWNLOAD_ERROR".to_string(),
            message: "Failed to download artifact: timeout".to_string(),
            launcher_version: "0.1.0-test".to_string(),
            os: "linux".to_string(),
            context: Some(json!({
                "filename": "otclient.exe",
                "stage": "download",
                "retryable": true
            })),
        };

        let response = client.report_error(&report).await.expect("report accepted");
        assert_eq!(response.status, "accepted");
        assert_eq!(response.id.as_deref(), Some("err-download-1"));

        let captured = server.wait();
        assert!(
            captured.request_line.starts_with("POST /error-report.php"),
            "unexpected request line: {}",
            captured.request_line
        );
        assert!(
            captured.headers.iter().any(|h| h
                .to_ascii_lowercase()
                .starts_with("content-type: application/json")),
            "missing application/json header: {:?}",
            captured.headers
        );

        let payload: Value = serde_json::from_str(&captured.body).expect("json payload");
        assert_eq!(payload["errorCode"], "DOWNLOAD_ERROR");
        assert_eq!(payload["message"], "Failed to download artifact: timeout");
        assert_eq!(payload["launcherVersion"], "0.1.0-test");
        assert_eq!(payload["os"], "linux");
        assert_eq!(payload["context"]["filename"], "otclient.exe");
    }

    #[tokio::test]
    async fn test_error_report_format() {
        let server =
            SingleRequestServer::start(200, r#"{"status":"accepted","id":"err-format-1"}"#);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let report = ErrorReportRequest {
            error_code: "frontend.download_failure".to_string(),
            message: "Network error while downloading launcher.msi".to_string(),
            launcher_version: "0.2.3".to_string(),
            os: "windows".to_string(),
            context: Some(json!({
                "screen": "downloads",
                "attempt": 2,
                "url": "https://example.invalid/launcher.msi"
            })),
        };

        let response = client.report_error(&report).await.expect("report accepted");
        assert_eq!(response.status, "accepted");

        let captured = server.wait();
        let payload: Value = serde_json::from_str(&captured.body).expect("json payload");
        let object = payload.as_object().expect("payload object");

        assert!(object.contains_key("errorCode"));
        assert!(object.contains_key("message"));
        assert!(object.contains_key("launcherVersion"));
        assert!(object.contains_key("os"));
        assert!(object.contains_key("context"));
        assert_eq!(
            object.get("errorCode").and_then(Value::as_str),
            Some("frontend.download_failure")
        );
    }

    #[tokio::test]
    async fn test_error_report_rate_limited() {
        let server = SingleRequestServer::start(429, r#"{"status":"rate_limited"}"#);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let report = ErrorReportRequest {
            error_code: "DOWNLOAD_ERROR".to_string(),
            message: "Failed to download artifact".to_string(),
            launcher_version: "0.1.0-test".to_string(),
            os: "linux".to_string(),
            context: None,
        };

        let result = client.report_error(&report).await;
        assert!(matches!(result, Err(ApiError::RateLimited)));

        let captured = server.wait();
        assert!(
            captured.request_line.starts_with("POST /error-report.php"),
            "unexpected request line: {}",
            captured.request_line
        );
    }
}
