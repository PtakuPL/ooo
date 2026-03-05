//! Download i weryfikacja paczek fontów Unicode (9.3.5/9.3.6).

use std::path::{Path, PathBuf};

use common_models::font_pack::FontPackInfo;
use launcher_api::client::ApiClient;

use crate::integrity::sha256_bytes;

/// Wynik pobrania paczki fontów.
#[derive(Debug, Clone)]
pub struct FontPackDownloadResult {
    pub cache_key: String,
    pub saved_path: PathBuf,
    pub size: u64,
    pub sha256: String,
}

/// Błędy pobierania i weryfikacji paczki fontów.
#[derive(Debug, thiserror::Error)]
pub enum FontPackDownloadError {
    #[error("Invalid font-pack metadata: {0}")]
    InvalidMetadata(String),

    #[error("Font-pack download failed: {0}")]
    DownloadFailed(String),

    #[error("Font-pack hash mismatch for '{cache_key}': expected {expected}, got {actual}")]
    HashMismatch {
        cache_key: String,
        expected: String,
        actual: String,
    },

    #[error(
        "Font-pack size mismatch for '{cache_key}': expected {expected} bytes, got {actual} bytes"
    )]
    SizeMismatch {
        cache_key: String,
        expected: u64,
        actual: u64,
    },

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),
}

/// Pobiera paczkę fontów, weryfikuje rozmiar i SHA-256, a następnie zapisuje do cache.
pub async fn download_font_pack(
    api_client: &ApiClient,
    font_pack: &FontPackInfo,
    cache_dir: &Path,
) -> Result<FontPackDownloadResult, FontPackDownloadError> {
    validate_font_pack_for_download(font_pack)?;

    let cache_key = font_pack.cache_key();
    let bytes = api_client
        .download_file(&font_pack.url)
        .await
        .map_err(|e| FontPackDownloadError::DownloadFailed(e.to_string()))?;

    let actual_size = bytes.len() as u64;
    if actual_size != font_pack.size {
        return Err(FontPackDownloadError::SizeMismatch {
            cache_key,
            expected: font_pack.size,
            actual: actual_size,
        });
    }

    let actual_sha256 = sha256_bytes(&bytes);
    if !actual_sha256.eq_ignore_ascii_case(&font_pack.sha256) {
        return Err(FontPackDownloadError::HashMismatch {
            cache_key,
            expected: font_pack.sha256.clone(),
            actual: actual_sha256,
        });
    }

    std::fs::create_dir_all(cache_dir)?;
    let file_name = font_pack_filename(font_pack);
    let saved_path = cache_dir.join(file_name);
    std::fs::write(&saved_path, &bytes)?;

    Ok(FontPackDownloadResult {
        cache_key: font_pack.cache_key(),
        saved_path,
        size: actual_size,
        sha256: font_pack.sha256.clone(),
    })
}

fn font_pack_filename(font_pack: &FontPackInfo) -> String {
    let fallback = format!(
        "{}-{}-{}.zip",
        sanitize_segment(&font_pack.locale),
        sanitize_segment(&font_pack.script),
        sanitize_segment(&font_pack.version)
    );

    let from_url = font_pack
        .url
        .rsplit('/')
        .next()
        .and_then(|part| part.split('?').next())
        .map(str::trim)
        .filter(|part| !part.is_empty())
        .and_then(|part| {
            Path::new(part)
                .file_name()
                .and_then(|name| name.to_str())
                .map(ToString::to_string)
        });

    from_url.unwrap_or(fallback)
}

fn validate_font_pack_for_download(font_pack: &FontPackInfo) -> Result<(), FontPackDownloadError> {
    if font_pack.locale.trim().is_empty() {
        return Err(FontPackDownloadError::InvalidMetadata(
            "locale cannot be empty".to_string(),
        ));
    }
    if font_pack.script.trim().is_empty() {
        return Err(FontPackDownloadError::InvalidMetadata(
            "script cannot be empty".to_string(),
        ));
    }
    if font_pack.version.trim().is_empty() {
        return Err(FontPackDownloadError::InvalidMetadata(
            "version cannot be empty".to_string(),
        ));
    }
    if font_pack.url.trim().is_empty() {
        return Err(FontPackDownloadError::InvalidMetadata(
            "url cannot be empty".to_string(),
        ));
    }

    // Produkcyjnie wymagamy HTTPS. Dopuszczamy loopback HTTP wyłącznie dla testów lokalnych.
    if !font_pack.url.starts_with("https://") && !is_loopback_http_url(&font_pack.url) {
        return Err(FontPackDownloadError::InvalidMetadata(
            "url must use HTTPS".to_string(),
        ));
    }

    if font_pack.sha256.len() != 64 || !font_pack.sha256.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(FontPackDownloadError::InvalidMetadata(
            "sha256 must be a 64-char hex string".to_string(),
        ));
    }
    if font_pack.size == 0 {
        return Err(FontPackDownloadError::InvalidMetadata(
            "size must be greater than zero".to_string(),
        ));
    }
    Ok(())
}

fn is_loopback_http_url(url: &str) -> bool {
    let lower = url.to_ascii_lowercase();
    lower.starts_with("http://127.0.0.1")
        || lower.starts_with("http://localhost")
        || lower.starts_with("http://[::1]")
}

fn sanitize_segment(value: &str) -> String {
    let sanitized: String = value
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '-' })
        .collect();
    if sanitized.is_empty() {
        "fontpack".to_string()
    } else {
        sanitized
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use launcher_api::client::ApiClientConfig;
    use std::io::{Read, Write};
    use std::net::TcpListener;
    use std::sync::{Arc, Mutex};
    use std::thread;
    use std::time::Duration;
    use tempfile::tempdir;

    #[derive(Debug, Clone)]
    struct CapturedRequest {
        request_line: String,
    }

    struct SingleResponseServer {
        base_url: String,
        captured: Arc<Mutex<Option<CapturedRequest>>>,
        handle: thread::JoinHandle<()>,
    }

    impl SingleResponseServer {
        fn start(status_code: u16, body: &[u8]) -> Self {
            let listener = TcpListener::bind("127.0.0.1:0").expect("bind test server");
            let addr = listener.local_addr().expect("local addr");
            let captured = Arc::new(Mutex::new(None));
            let captured_clone = Arc::clone(&captured);
            let payload = body.to_vec();

            let handle = thread::spawn(move || {
                let (mut stream, _) = listener.accept().expect("accept");
                stream
                    .set_read_timeout(Some(Duration::from_secs(2)))
                    .expect("set timeout");

                let mut buf = [0_u8; 2048];
                let n = stream.read(&mut buf).expect("read request");
                let request_text = String::from_utf8_lossy(&buf[..n]).to_string();
                let request_line = request_text.lines().next().unwrap_or_default().to_string();
                *captured_clone.lock().expect("lock captured") =
                    Some(CapturedRequest { request_line });

                let reason = match status_code {
                    200 => "OK",
                    404 => "Not Found",
                    500 => "Internal Server Error",
                    _ => "OK",
                };

                let headers = format!(
                    "HTTP/1.1 {} {}\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                    status_code,
                    reason,
                    payload.len()
                );
                stream.write_all(headers.as_bytes()).expect("write headers");
                stream.write_all(&payload).expect("write body");
                stream.flush().expect("flush body");
            });

            Self {
                base_url: format!("http://{}", addr),
                captured,
                handle,
            }
        }

        fn wait(self) -> CapturedRequest {
            self.handle.join().expect("join server thread");
            self.captured
                .lock()
                .expect("lock captured")
                .clone()
                .expect("captured request")
        }
    }

    fn sample_font_pack(url: String, sha256: String, size: u64) -> FontPackInfo {
        FontPackInfo {
            locale: "ar".to_string(),
            script: "arabic".to_string(),
            version: "1.0.0".to_string(),
            url,
            sha256,
            size,
            bundled: false,
        }
    }

    #[tokio::test]
    async fn test_download_font_pack_ok() {
        let body = b"font-pack-binary-data-v1".to_vec();
        let sha = sha256_bytes(&body);
        let server = SingleResponseServer::start(200, &body);
        let url = format!("{}/packs/ar-1.0.0.zip", server.base_url);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let info = sample_font_pack(url, sha.clone(), body.len() as u64);
        let cache_dir = tempdir().expect("tempdir");

        let result = download_font_pack(&client, &info, cache_dir.path())
            .await
            .expect("download font pack");
        assert_eq!(result.cache_key, "ar:arabic:1.0.0");
        assert_eq!(result.size, body.len() as u64);
        assert_eq!(result.sha256, sha);
        assert!(result.saved_path.exists());
        assert_eq!(std::fs::read(&result.saved_path).expect("read file"), body);

        let captured = server.wait();
        assert!(
            captured
                .request_line
                .starts_with("GET /packs/ar-1.0.0.zip HTTP/"),
            "unexpected request line: {}",
            captured.request_line
        );
    }

    #[tokio::test]
    async fn test_download_font_pack_hash_mismatch() {
        let body = b"font-pack-binary-data-v1".to_vec();
        let server = SingleResponseServer::start(200, &body);
        let url = format!("{}/packs/ar-1.0.0.zip", server.base_url);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let info = sample_font_pack(url, "0".repeat(64), body.len() as u64);
        let cache_dir = tempdir().expect("tempdir");
        let expected_path = cache_dir.path().join("ar-1.0.0.zip");

        let result = download_font_pack(&client, &info, cache_dir.path()).await;
        assert!(matches!(
            result,
            Err(FontPackDownloadError::HashMismatch { .. })
        ));
        assert!(!expected_path.exists());
    }

    #[tokio::test]
    async fn test_download_font_pack_size_mismatch() {
        let body = b"font-pack-binary-data-v1".to_vec();
        let sha = sha256_bytes(&body);
        let server = SingleResponseServer::start(200, &body);
        let url = format!("{}/packs/ar-1.0.0.zip", server.base_url);

        let client = ApiClient::new(ApiClientConfig {
            base_url: server.base_url.clone(),
            timeout_seconds: 5,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let info = sample_font_pack(url, sha, (body.len() as u64) + 1);
        let cache_dir = tempdir().expect("tempdir");
        let expected_path = cache_dir.path().join("ar-1.0.0.zip");

        let result = download_font_pack(&client, &info, cache_dir.path()).await;
        assert!(matches!(
            result,
            Err(FontPackDownloadError::SizeMismatch { .. })
        ));
        assert!(!expected_path.exists());
    }

    #[tokio::test]
    async fn test_download_font_pack_rejects_non_https_non_loopback() {
        let client = ApiClient::new(ApiClientConfig {
            base_url: "http://127.0.0.1:1".to_string(),
            timeout_seconds: 1,
            max_retries: 0,
            ..Default::default()
        })
        .expect("client");

        let info = sample_font_pack(
            "http://cdn.example.com/fonts/ar-1.0.0.zip".to_string(),
            "a".repeat(64),
            123,
        );
        let cache_dir = tempdir().expect("tempdir");

        let result = download_font_pack(&client, &info, cache_dir.path()).await;
        assert!(matches!(
            result,
            Err(FontPackDownloadError::InvalidMetadata(_))
        ));
    }
}
