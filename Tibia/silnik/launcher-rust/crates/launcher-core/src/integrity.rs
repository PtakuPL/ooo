//! LR-082: Referencyjne compute_files_hash() zgodne z planem.
//!
//! Algorytm filesHash:
//! 1. Weź manifest.files[] gdzie managed=true AND action=file AND includeInFilesHash=true
//! 2. Sortuj po path rosnąco (UTF-8 lexicographic)
//! 3. Dla każdego: jeśli plik istnieje → SHA-256; jeśli brak → "MISSING"
//! 4. Sklej wartości w jeden string
//! 5. SHA-256 z połączonego stringa → hex = filesHash
//!
//! KRYTYCZNE: filesHash liczymy z LOKALNYCH plików, nie z sha256 z manifestu.

use sha2::{Digest, Sha256};
use std::io::Read;
use std::path::{Path, PathBuf};

use common_models::manifest::{ManifestFileAction, NormalizedManifest};

/// Oblicza SHA-256 pojedynczego pliku.
pub fn sha256_file(path: &Path) -> std::io::Result<String> {
    let mut file = std::fs::File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buffer = [0u8; 8192];

    loop {
        let bytes_read = file.read(&mut buffer)?;
        if bytes_read == 0 {
            break;
        }
        hasher.update(&buffer[..bytes_read]);
    }

    Ok(format!("{:x}", hasher.finalize()))
}

/// Oblicza SHA-256 z bajt-slajsu (do filesHash).
pub fn sha256_bytes(data: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    format!("{:x}", hasher.finalize())
}

/// LR-082: Referencyjne obliczenie filesHash.
///
/// `client_dir` — ścieżka do katalogu klienta (gdzie leżą pliki z manifestu).
///
/// Zwraca hex SHA-256 lub błąd I/O.
pub fn compute_files_hash(
    manifest: &NormalizedManifest,
    client_dir: &Path,
) -> Result<String, FilesHashError> {
    // 1. Filtruj: managed=true, action=file, includeInFilesHash=true
    let mut entries: Vec<&str> = manifest
        .files
        .iter()
        .filter(|f| f.managed && f.action == ManifestFileAction::File && f.include_in_files_hash)
        .map(|f| f.path.as_str())
        .collect();

    // 2. Sortuj po path rosnąco
    entries.sort();

    // 3+4. Dla każdego pliku: hash lokalny lub "MISSING", sklej
    let mut combined = String::new();
    for path in &entries {
        let full_path = client_dir.join(path);
        let hash = if full_path.exists() {
            sha256_file(&full_path).map_err(|e| FilesHashError::IoError {
                path: path.to_string(),
                source: e,
            })?
        } else {
            "MISSING".to_string()
        };
        combined.push_str(&hash);
    }

    // 5. SHA-256 z połączonego stringa
    Ok(sha256_bytes(combined.as_bytes()))
}

#[derive(Debug, thiserror::Error)]
pub enum FilesHashError {
    #[error("I/O error reading '{path}': {source}")]
    IoError {
        path: String,
        #[source]
        source: std::io::Error,
    },
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;
    use common_models::manifest::parse_manifest_compat;
    use std::fs;

    #[test]
    fn test_sha256_bytes() {
        // SHA-256 of empty string
        let hash = sha256_bytes(b"");
        assert_eq!(
            hash,
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        );
    }

    #[test]
    fn test_sha256_bytes_hello() {
        let hash = sha256_bytes(b"hello");
        assert_eq!(
            hash,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        );
    }

    #[test]
    fn test_compute_files_hash_all_missing() {
        // Gdy żaden plik nie istnieje lokalnie → filesHash z "MISSING"*N
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        let result = compute_files_hash(&manifest, tmp.path());
        assert!(result.is_ok());
        let hash = result.unwrap();
        // Hash powinien być deterministyczny
        assert!(!hash.is_empty());
        assert_eq!(hash.len(), 64); // hex SHA-256
    }

    #[test]
    fn test_compute_files_hash_with_files() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        // Utwórz pliki o znanej treści
        fs::write(tmp.path().join("a.txt"), b"hello").expect("write a");
        fs::write(tmp.path().join("b.txt"), b"world").expect("write b");

        let hash = compute_files_hash(&manifest, tmp.path()).expect("hash");
        assert_eq!(hash.len(), 64);

        // Zmień plik → filesHash się zmieni
        fs::write(tmp.path().join("a.txt"), b"changed").expect("write a2");
        let hash2 = compute_files_hash(&manifest, tmp.path()).expect("hash2");
        assert_ne!(hash, hash2, "Zmiana pliku powinna zmienić filesHash");
    }

    #[test]
    fn test_compute_files_hash_missing_gives_different_than_present() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");

        // Hash z brakującymi plikami
        let hash_missing = compute_files_hash(&manifest, tmp.path()).expect("h1");

        // Teraz utwórz pliki
        fs::write(tmp.path().join("a.txt"), b"content").expect("w");
        fs::write(tmp.path().join("b.txt"), b"content2").expect("w2");
        let hash_present = compute_files_hash(&manifest, tmp.path()).expect("h2");

        assert_ne!(hash_missing, hash_present);
    }
}
