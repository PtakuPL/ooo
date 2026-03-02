//! Klient API launchera — stub do implementacji w Sprint 2 (LR-013).
//!
//! Na razie eksportuje tylko typy, żeby workspace cargo się kompilował.

/// Konfiguracja klienta API.
#[derive(Debug, Clone)]
pub struct ApiClientConfig {
    pub base_url: String,
    pub timeout_seconds: u64,
    pub max_retries: u32,
}

impl Default for ApiClientConfig {
    fn default() -> Self {
        Self {
            base_url: String::new(),
            timeout_seconds: 30,
            max_retries: 3,
        }
    }
}

/// Klient API — implementacja w LR-013.
pub struct ApiClient {
    pub config: ApiClientConfig,
}

impl ApiClient {
    pub fn new(config: ApiClientConfig) -> Self {
        Self { config }
    }
}
