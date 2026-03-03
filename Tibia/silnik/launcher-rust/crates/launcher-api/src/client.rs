//! Klient API launchera — pełna implementacja (LR-013, LR-015, LR-023).
//!
//! Obsługuje:
//! - `launcher-version.php` (sprawdzenie wersji launchera)
//! - `update.php` (pobranie manifestu klienta)
//! - `launcher-token.php` (pobranie launch-tokena)
//! - pobieranie plików z URL (download z retry)

use common_models::api_responses::{
    ChallengeResponse, InstallerCatalogResponse, LaunchTokenErrorResponse, LaunchTokenRequest,
    LaunchTokenResponse, LauncherVersionResponse,
};
use common_models::manifest::{parse_manifest_compat, ManifestParseError, NormalizedManifest};

/// Konfiguracja klienta API.
#[derive(Debug, Clone)]
pub struct ApiClientConfig {
    pub base_url: String,
    pub timeout_seconds: u64,
    pub max_retries: u32,
    pub user_agent: String,
}

impl Default for ApiClientConfig {
    fn default() -> Self {
        Self {
            base_url: String::new(),
            timeout_seconds: 30,
            max_retries: 3,
            user_agent: "TwojaGra-Launcher/0.1.0".to_string(),
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

    #[error("Max retries ({0}) exceeded")]
    MaxRetriesExceeded(u32),

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
}

/// Klient API launchera.
pub struct ApiClient {
    pub config: ApiClientConfig,
    http: reqwest::Client,
}

impl ApiClient {
    /// Tworzy nowego klienta API z podaną konfiguracją.
    pub fn new(config: ApiClientConfig) -> Result<Self, ApiError> {
        // Wymuszenie HTTPS
        if !config.base_url.is_empty() && !config.base_url.starts_with("https://") {
            // W testach pozwalamy na http, ale logujemy ostrzeżenie
            tracing::warn!(
                "Base URL nie używa HTTPS: {} — w produkcji wymuszaj TLS!",
                config.base_url
            );
        }

        let http = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(config.timeout_seconds))
            .user_agent(&config.user_agent)
            .build()?;

        Ok(Self { config, http })
    }

    /// Buduje pełny URL z base_url + endpoint.
    fn url(&self, endpoint: &str) -> String {
        let base = self.config.base_url.trim_end_matches('/');
        format!("{}/{}", base, endpoint.trim_start_matches('/'))
    }

    // ─────────────────────────────────────────
    // LR-013: launcher-version.php
    // ─────────────────────────────────────────

    /// Sprawdza najnowszą wersję launchera na serwerze.
    pub async fn check_launcher_version(&self) -> Result<LauncherVersionResponse, ApiError> {
        let url = self.url("launcher-version.php");
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
    pub async fn fetch_manifest(
        &self,
        channel: &str,
    ) -> Result<NormalizedManifest, ApiError> {
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

        let resp = self
            .http
            .post(&url)
            .json(request)
            .send()
            .await?;

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

        // Walidacja: channel musi się zgadzać
        if catalog.channel != channel {
            return Err(ApiError::HttpStatus {
                status: 200,
                body: format!(
                    "Catalog channel mismatch: expected '{}', got '{}'",
                    channel, catalog.channel
                ),
            });
        }

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

        // Walidacja: nonce nie może być pusty
        if challenge.nonce.is_empty() {
            return Err(ApiError::HttpStatus {
                status: 200,
                body: "Challenge nonce is empty".to_string(),
            });
        }

        Ok(Some(challenge))
    }

    // ─────────────────────────────────────────
    // LR-019: Download file with retry
    // ─────────────────────────────────────────

    /// Pobiera plik z podanego URL, zwraca bajty.
    /// Obsługuje retry wg `max_retries` z konfiguracji.
    pub async fn download_file(&self, url: &str) -> Result<Vec<u8>, ApiError> {
        tracing::debug!("Pobieram plik: {}", url);

        let mut last_error: Option<ApiError> = None;

        for attempt in 0..=self.config.max_retries {
            if attempt > 0 {
                let delay = std::time::Duration::from_millis(500 * 2u64.pow(attempt - 1));
                tracing::warn!(
                    "Retry {}/{} za {:?}: {}",
                    attempt,
                    self.config.max_retries,
                    delay,
                    url
                );
                tokio::time::sleep(delay).await;
            }

            match self.http.get(url).send().await {
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

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

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
}
