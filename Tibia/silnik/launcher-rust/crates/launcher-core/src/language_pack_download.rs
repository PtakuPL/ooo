//! Faza 9.4: pobieranie i instalacja paczek językowych.
//!
//! Zakres:
//! - walidacja metadanych paczki,
//! - pobranie archiwum zip,
//! - weryfikacja size + SHA-256,
//! - bezpieczne rozpakowanie (ochrona przed path traversal),
//! - zapis metadanych lokalnej instalacji.

use std::fs::File;
use std::io::Cursor;
use std::path::{Path, PathBuf};

use common_models::api_responses::LanguagePackInfo;
use launcher_api::client::ApiClient;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use zip::ZipArchive;

use crate::integrity::sha256_bytes;

const PACK_METADATA_FILE: &str = ".launcher_pack.json";

#[derive(Debug, Clone)]
pub struct LanguagePackInstallResult {
    pub locale: String,
    pub version: String,
    pub cache_key: String,
    pub archive_path: PathBuf,
    pub install_dir: PathBuf,
    pub file_count: u32,
    pub total_unpacked_bytes: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstalledLanguagePack {
    pub locale: String,
    pub version: String,
    pub install_dir: PathBuf,
    pub metadata_path: PathBuf,
}

#[derive(Debug, thiserror::Error)]
pub enum LanguagePackDownloadError {
    #[error("Invalid language-pack metadata: {0}")]
    InvalidMetadata(String),

    #[error("Language pack for locale '{0}' is bundled and should not be downloaded")]
    AlreadyBundled(String),

    #[error("Missing download field '{field}' for locale '{locale}'")]
    MissingDownloadField { locale: String, field: &'static str },

    #[error("Language-pack download failed: {0}")]
    DownloadFailed(String),

    #[error(
        "Language-pack hash mismatch for locale '{locale}' v{version}: expected {expected}, got {actual}"
    )]
    HashMismatch {
        locale: String,
        version: String,
        expected: String,
        actual: String,
    },

    #[error(
        "Language-pack size mismatch for locale '{locale}' v{version}: expected {expected} bytes, got {actual} bytes"
    )]
    SizeMismatch {
        locale: String,
        version: String,
        expected: u64,
        actual: u64,
    },

    #[error("Archive entry path is unsafe: {0}")]
    InvalidArchivePath(String),

    #[error("Zip error: {0}")]
    Zip(#[from] zip::result::ZipError),

    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),
}

#[derive(Debug, Clone, Copy)]
struct ExtractionSummary {
    file_count: u32,
    total_unpacked_bytes: u64,
}

/// Pobiera i instaluje paczkę językową do lokalnego katalogu launchera.
pub async fn download_language_pack(
    api_client: &ApiClient,
    pack: &LanguagePackInfo,
    packs_root_dir: &Path,
) -> Result<LanguagePackInstallResult, LanguagePackDownloadError> {
    validate_language_pack_for_download(pack)?;

    let locale = pack.locale.trim().to_string();
    let version = pack.version.trim().to_string();
    let cache_key = format!("{locale}:{version}");

    let url = pack
        .url
        .as_deref()
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: locale.clone(),
            field: "url",
        })?;
    let expected_sha = pack
        .sha256
        .as_deref()
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: locale.clone(),
            field: "sha256",
        })?;
    let expected_size = pack
        .size
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: locale.clone(),
            field: "size",
        })?;

    let bytes = api_client
        .download_file(url)
        .await
        .map_err(|e| LanguagePackDownloadError::DownloadFailed(e.to_string()))?;

    let actual_size = bytes.len() as u64;
    if actual_size != expected_size {
        return Err(LanguagePackDownloadError::SizeMismatch {
            locale,
            version,
            expected: expected_size,
            actual: actual_size,
        });
    }

    let actual_sha = sha256_bytes(&bytes);
    if !actual_sha.eq_ignore_ascii_case(expected_sha) {
        return Err(LanguagePackDownloadError::HashMismatch {
            locale,
            version,
            expected: expected_sha.to_string(),
            actual: actual_sha,
        });
    }

    let cache_dir = packs_root_dir.join("cache");
    let installed_dir = packs_root_dir.join("installed");
    let staging_dir = packs_root_dir.join("staging");
    std::fs::create_dir_all(&cache_dir)?;
    std::fs::create_dir_all(&installed_dir)?;
    std::fs::create_dir_all(&staging_dir)?;

    let archive_name = language_pack_archive_filename(pack);
    let archive_path = cache_dir.join(archive_name);
    std::fs::write(&archive_path, &bytes)?;

    let install_key = format!(
        "{}-{}",
        sanitize_segment(&pack.locale),
        sanitize_segment(&pack.version)
    );
    let unpack_staging = staging_dir.join(format!("{install_key}-{}", Uuid::new_v4()));
    std::fs::create_dir_all(&unpack_staging)?;

    let extraction = extract_zip_archive(&bytes, &unpack_staging)?;
    let metadata_path = unpack_staging.join(PACK_METADATA_FILE);
    std::fs::write(&metadata_path, serde_json::to_vec_pretty(pack)?)?;

    let final_install_dir = installed_dir.join(install_key);
    if final_install_dir.exists() {
        std::fs::remove_dir_all(&final_install_dir)?;
    }
    std::fs::rename(&unpack_staging, &final_install_dir)?;

    Ok(LanguagePackInstallResult {
        locale: pack.locale.clone(),
        version: pack.version.clone(),
        cache_key,
        archive_path,
        install_dir: final_install_dir,
        file_count: extraction.file_count,
        total_unpacked_bytes: extraction.total_unpacked_bytes,
    })
}

/// Zwraca listę paczek językowych już zainstalowanych lokalnie.
pub fn list_installed_packs(
    packs_root_dir: &Path,
) -> Result<Vec<InstalledLanguagePack>, LanguagePackDownloadError> {
    let installed_dir = packs_root_dir.join("installed");
    if !installed_dir.exists() {
        return Ok(Vec::new());
    }

    let mut result = Vec::new();
    for entry in std::fs::read_dir(installed_dir)? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_dir() {
            continue;
        }

        let metadata_path = path.join(PACK_METADATA_FILE);
        if !metadata_path.exists() {
            continue;
        }

        let raw = std::fs::read(&metadata_path)?;
        let metadata: LanguagePackInfo = serde_json::from_slice(&raw)?;
        result.push(InstalledLanguagePack {
            locale: metadata.locale,
            version: metadata.version,
            install_dir: path,
            metadata_path,
        });
    }

    result.sort_by(|a, b| {
        a.locale
            .cmp(&b.locale)
            .then_with(|| a.version.cmp(&b.version))
    });
    Ok(result)
}

fn validate_language_pack_for_download(
    pack: &LanguagePackInfo,
) -> Result<(), LanguagePackDownloadError> {
    if pack.locale.trim().is_empty() {
        return Err(LanguagePackDownloadError::InvalidMetadata(
            "locale cannot be empty".to_string(),
        ));
    }
    if pack.version.trim().is_empty() {
        return Err(LanguagePackDownloadError::InvalidMetadata(
            "version cannot be empty".to_string(),
        ));
    }
    if pack.bundled {
        return Err(LanguagePackDownloadError::AlreadyBundled(pack.locale.clone()));
    }

    let url = pack
        .url
        .as_deref()
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: pack.locale.clone(),
            field: "url",
        })?;
    if !url.starts_with("https://") && !is_loopback_http_url(url) {
        return Err(LanguagePackDownloadError::InvalidMetadata(
            "url must use HTTPS".to_string(),
        ));
    }

    let sha = pack
        .sha256
        .as_deref()
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: pack.locale.clone(),
            field: "sha256",
        })?;
    if sha.len() != 64 || !sha.chars().all(|c| c.is_ascii_hexdigit()) {
        return Err(LanguagePackDownloadError::InvalidMetadata(
            "sha256 must be a 64-char hex string".to_string(),
        ));
    }

    let size = pack
        .size
        .ok_or_else(|| LanguagePackDownloadError::MissingDownloadField {
            locale: pack.locale.clone(),
            field: "size",
        })?;
    if size == 0 {
        return Err(LanguagePackDownloadError::InvalidMetadata(
            "size must be greater than zero".to_string(),
        ));
    }

    Ok(())
}

fn extract_zip_archive(
    bytes: &[u8],
    destination: &Path,
) -> Result<ExtractionSummary, LanguagePackDownloadError> {
    let cursor = Cursor::new(bytes);
    let mut archive = ZipArchive::new(cursor)?;
    let mut file_count: u32 = 0;
    let mut total_unpacked_bytes: u64 = 0;

    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let entry_name = entry.name().to_string();
        let enclosed = entry
            .enclosed_name()
            .ok_or(LanguagePackDownloadError::InvalidArchivePath(entry_name))?;
        let output_path = destination.join(enclosed);

        if entry.is_dir() {
            std::fs::create_dir_all(&output_path)?;
            continue;
        }

        if let Some(parent) = output_path.parent() {
            std::fs::create_dir_all(parent)?;
        }

        let mut output_file = File::create(&output_path)?;
        let copied = std::io::copy(&mut entry, &mut output_file)?;
        file_count += 1;
        total_unpacked_bytes += copied;
    }

    Ok(ExtractionSummary {
        file_count,
        total_unpacked_bytes,
    })
}

fn language_pack_archive_filename(pack: &LanguagePackInfo) -> String {
    let from_url = pack
        .url
        .as_deref()
        .and_then(|url| url.rsplit('/').next())
        .and_then(|part| part.split('?').next())
        .map(str::trim)
        .filter(|part| !part.is_empty())
        .and_then(|part| {
            Path::new(part)
                .file_name()
                .and_then(|name| name.to_str())
                .map(ToString::to_string)
        });

    from_url.unwrap_or_else(|| {
        format!(
            "{}-{}.zip",
            sanitize_segment(&pack.locale),
            sanitize_segment(&pack.version)
        )
    })
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
        "pack".to_string()
    } else {
        sanitized
    }
}

