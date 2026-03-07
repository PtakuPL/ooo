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
// LR-085: Weryfikacja plików krytycznych przed launch
// ─────────────────────────────────────────────

use common_models::manifest::CriticalFileEntry;

/// Wynik weryfikacji pojedynczego pliku krytycznego.
#[derive(Debug, Clone)]
pub enum CriticalFileStatus {
    /// Hash zgadza się z manifestem.
    Ok,
    /// Plik istnieje ale hash nie zgadza się.
    Modified { expected: String, actual: String },
    /// Plik nie istnieje na dysku.
    Missing,
    /// Błąd odczytu pliku.
    ReadError(String),
}

/// Wynik weryfikacji wszystkich plików krytycznych.
#[derive(Debug, Clone)]
pub struct CriticalFilesReport {
    /// Pliki które przeszły weryfikację.
    pub ok_count: u32,
    /// Pliki zmodyfikowane (hash niezgodny).
    pub modified: Vec<String>,
    /// Pliki brakujące.
    pub missing: Vec<String>,
    /// Pliki z błędem odczytu.
    pub errors: Vec<String>,
    /// Czy weryfikacja się powiodła (brak modified + missing + errors).
    pub passed: bool,
}

/// LR-085: Weryfikuje SHA-256 plików krytycznych przed uruchomieniem klienta.
///
/// `critical_files` — lista z manifestu (path + expected sha256).
/// `client_dir` — katalog instalacji klienta.
///
/// Zwraca raport: które pliki OK, które zmodyfikowane, które brakujące.
pub fn verify_critical_files(
    critical_files: &[CriticalFileEntry],
    client_dir: &Path,
) -> CriticalFilesReport {
    let mut ok_count: u32 = 0;
    let mut modified = Vec::new();
    let mut missing = Vec::new();
    let mut errors = Vec::new();

    for cf in critical_files {
        let full_path = client_dir.join(&cf.path);

        if !full_path.exists() {
            missing.push(cf.path.clone());
            continue;
        }

        match sha256_file(&full_path) {
            Ok(actual_hash) => {
                if actual_hash == cf.sha256 {
                    ok_count += 1;
                } else {
                    modified.push(cf.path.clone());
                }
            }
            Err(e) => {
                errors.push(format!("{}: {}", cf.path, e));
            }
        }
    }

    let passed = modified.is_empty() && missing.is_empty() && errors.is_empty();

    CriticalFilesReport {
        ok_count,
        modified,
        missing,
        errors,
        passed,
    }
}

/// Wynik kwarantanny plikow krytycznych.
#[derive(Debug, Clone)]
pub struct QuarantineResult {
    /// Katalog, do ktorego przeniesiono pliki.
    pub quarantine_dir: PathBuf,
    /// Lista sciezek przeniesionych poprawnie.
    pub moved_files: Vec<String>,
    /// Lista bledow przeniesienia.
    pub failed_files: Vec<String>,
}

fn copy_and_remove(src: &Path, dst: &Path) -> std::io::Result<()> {
    std::fs::copy(src, dst)?;
    std::fs::remove_file(src)?;
    Ok(())
}

/// Przenosi zmodyfikowane pliki krytyczne do kwarantanny.
///
/// Uwaga: `relative_paths` powinny byc sciezkami wzglednymi wzgledem `client_dir`.
pub fn quarantine_critical_files(
    relative_paths: &[String],
    client_dir: &Path,
    quarantine_root: &Path,
) -> QuarantineResult {
    let stamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);

    let quarantine_dir = quarantine_root.join(format!("critical-{stamp}"));
    let mut moved_files = Vec::new();
    let mut failed_files = Vec::new();

    if let Err(e) = std::fs::create_dir_all(&quarantine_dir) {
        failed_files.push(format!(
            "<init>: nie mozna utworzyc katalogu kwarantanny {}: {}",
            quarantine_dir.display(),
            e
        ));
        return QuarantineResult {
            quarantine_dir,
            moved_files,
            failed_files,
        };
    }

    for rel in relative_paths {
        let src = client_dir.join(rel);
        if !src.exists() {
            continue;
        }

        let dst = quarantine_dir.join(rel);
        if let Some(parent) = dst.parent() {
            if let Err(e) = std::fs::create_dir_all(parent) {
                failed_files.push(format!("{}: mkdir failed: {}", rel, e));
                continue;
            }
        }

        match std::fs::rename(&src, &dst) {
            Ok(_) => moved_files.push(rel.clone()),
            Err(rename_err) => {
                match copy_and_remove(&src, &dst) {
                    Ok(_) => moved_files.push(rel.clone()),
                    Err(copy_err) => failed_files.push(format!(
                        "{}: rename failed: {}; copy+remove failed: {}",
                        rel, rename_err, copy_err
                    )),
                }
            }
        }
    }

    QuarantineResult {
        quarantine_dir,
        moved_files,
        failed_files,
    }
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

    // ─── verify_critical_files tests ───

    #[test]
    fn test_critical_files_all_ok() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let content = b"test content";
        fs::write(tmp.path().join("init.lua"), content).expect("write");
        let hash = sha256_file(&tmp.path().join("init.lua")).expect("hash");

        let critical = vec![CriticalFileEntry {
            path: "init.lua".into(),
            sha256: hash,
        }];

        let report = verify_critical_files(&critical, tmp.path());
        assert!(report.passed);
        assert_eq!(report.ok_count, 1);
        assert!(report.modified.is_empty());
        assert!(report.missing.is_empty());
    }

    #[test]
    fn test_critical_file_modified_detected() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        fs::write(tmp.path().join("init.lua"), b"original").expect("write");

        let critical = vec![CriticalFileEntry {
            path: "init.lua".into(),
            sha256: "0000000000000000000000000000000000000000000000000000000000000000".into(),
        }];

        let report = verify_critical_files(&critical, tmp.path());
        assert!(!report.passed);
        assert_eq!(report.modified.len(), 1);
        assert_eq!(report.modified[0], "init.lua");
    }

    #[test]
    fn test_critical_file_missing_detected() {
        let tmp = tempfile::tempdir().expect("tmpdir");

        let critical = vec![CriticalFileEntry {
            path: "init.lua".into(),
            sha256: "abc".into(),
        }];

        let report = verify_critical_files(&critical, tmp.path());
        assert!(!report.passed);
        assert_eq!(report.missing.len(), 1);
        assert_eq!(report.missing[0], "init.lua");
    }

    #[test]
    fn test_critical_files_empty_list() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let report = verify_critical_files(&[], tmp.path());
        assert!(report.passed);
        assert_eq!(report.ok_count, 0);
    }

    #[test]
    fn test_critical_files_subdirectory() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        let subdir = tmp.path().join("modules/client_entergame");
        fs::create_dir_all(&subdir).expect("mkdir");
        fs::write(subdir.join("entergame.lua"), b"game code").expect("write");
        let hash = sha256_file(&subdir.join("entergame.lua")).expect("hash");

        let critical = vec![CriticalFileEntry {
            path: "modules/client_entergame/entergame.lua".into(),
            sha256: hash,
        }];

        let report = verify_critical_files(&critical, tmp.path());
        assert!(report.passed);
        assert_eq!(report.ok_count, 1);
    }
}
