use std::io::{self, Read, Write};

use reqwest::blocking::Client;
use sha2::{Digest, Sha256};

use crate::i18n;
use crate::ui;

/// Error type for download operations.
#[derive(Debug)]
pub enum DownloadError {
    Http(String),
    HashMismatch { expected: String, got: String },
    Io(io::Error),
}

impl std::fmt::Display for DownloadError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let s = i18n::t();
        match self {
            Self::Http(msg) => write!(f, "{}: {msg}", s.error_download),
            Self::HashMismatch { expected, got } => {
                write!(f, "{} ({expected} \u{2260} {got})", s.error_hash_mismatch)
            }
            Self::Io(e) => write!(f, "{}: {e}", s.error_io),
        }
    }
}

impl From<io::Error> for DownloadError {
    fn from(e: io::Error) -> Self {
        Self::Io(e)
    }
}

const MAX_RETRIES: u32 = 3;
const CHUNK_SIZE: usize = 64 * 1024; // 64 KB

/// Download a file from `url`, verify its SHA-256 against `expected_sha256` (hex,
/// lowercase), and write the result to `dest`.  Reports progress via `ui::set_progress`.
///
/// Retries up to [`MAX_RETRIES`] times on transient HTTP errors.
pub fn download_and_verify(
    client: &Client,
    url: &str,
    expected_sha256: &str,
    dest: &std::path::Path,
) -> Result<(), DownloadError> {
    let mut last_err: Option<DownloadError> = None;

    for attempt in 1..=MAX_RETRIES {
        match try_download(client, url, expected_sha256, dest) {
            Ok(()) => return Ok(()),
            Err(e) => {
                if attempt < MAX_RETRIES {
                    let s = i18n::t();
                    ui::set_status(&format!("{attempt}/{MAX_RETRIES} {}", s.retry_message));
                }
                last_err = Some(e);
            }
        }
    }

    Err(last_err.unwrap())
}

fn try_download(
    client: &Client,
    url: &str,
    expected_sha256: &str,
    dest: &std::path::Path,
) -> Result<(), DownloadError> {
    let expected = expected_sha256.trim().to_ascii_lowercase();
    let expected_is_valid_hex =
        expected.len() == 64 && expected.chars().all(|c| matches!(c, '0'..='9' | 'a'..='f'));
    if !expected_is_valid_hex {
        return Err(DownloadError::HashMismatch {
            expected,
            got: "invalid expected SHA-256".to_string(),
        });
    }

    let resp = client
        .get(url)
        .send()
        .map_err(|e| DownloadError::Http(e.to_string()))?;

    if !resp.status().is_success() {
        return Err(DownloadError::Http(format!("HTTP {}", resp.status())));
    }

    let total_size = resp.content_length().unwrap_or(0);
    let mut reader = resp;
    let mut file = std::fs::File::create(dest).map_err(DownloadError::Io)?;

    let mut hasher = Sha256::new();
    let mut downloaded: u64 = 0;
    let mut buf = vec![0u8; CHUNK_SIZE];

    loop {
        let n = reader.read(&mut buf).map_err(DownloadError::Io)?;
        if n == 0 {
            break;
        }
        file.write_all(&buf[..n]).map_err(DownloadError::Io)?;
        hasher.update(&buf[..n]);
        downloaded += n as u64;

        if total_size > 0 {
            let pct = ((downloaded as f64 / total_size as f64) * 100.0) as u8;
            ui::set_progress(pct);
        }
    }

    file.flush().map_err(DownloadError::Io)?;
    drop(file);

    // Verify SHA-256 — empty/invalid expected hashes are rejected to keep
    // the bootstrap trust chain anchored. Callers (main.rs) should pre-validate
    // the catalog value, but we double-check here as a defense-in-depth gate.
    let hash = format!("{:x}", hasher.finalize());
    if hash != expected {
        // Remove corrupted/unverified file
        let _ = std::fs::remove_file(dest);
        return Err(DownloadError::HashMismatch {
            expected,
            got: hash,
        });
    }

    ui::set_progress(100);
    Ok(())
}

/// Fetch JSON from a URL (small payload, no progress tracking).
pub fn fetch_json(client: &Client, url: &str) -> Result<String, DownloadError> {
    let resp = client
        .get(url)
        .send()
        .map_err(|e| DownloadError::Http(e.to_string()))?;

    if !resp.status().is_success() {
        return Err(DownloadError::Http(format!("HTTP {}", resp.status())));
    }

    resp.text().map_err(|e| DownloadError::Http(e.to_string()))
}
