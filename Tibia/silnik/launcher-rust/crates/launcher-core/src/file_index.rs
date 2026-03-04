//! LR-016: Skan lokalnych plików i SHA-256 per plik.
//!
//! Moduł `file_index` skanuje katalog klienta i tworzy indeks
//! lokalnych plików z ich hashami SHA-256. Używany przez planner
//! do porównania z manifestem.

use std::collections::BTreeMap;
use std::path::Path;

use common_models::manifest::NormalizedManifest;

use crate::integrity::sha256_file;

/// Wynik skanu lokalnych plików.
#[derive(Debug, Clone, Default)]
pub struct LocalFileIndex {
    /// Mapa: ścieżka względna → hash SHA-256 (hex).
    pub files: BTreeMap<String, LocalFileInfo>,
}

/// Info o lokalnym pliku.
#[derive(Debug, Clone)]
pub struct LocalFileInfo {
    /// SHA-256 pliku (hex lowercase).
    pub sha256: String,
    /// Rozmiar w bajtach.
    pub size: u64,
    /// Czy plik istnieje na dysku.
    pub exists: bool,
}

/// Błąd skanu plików.
#[derive(Debug, thiserror::Error)]
pub enum FileIndexError {
    #[error("I/O error reading '{path}': {source}")]
    IoError {
        path: String,
        #[source]
        source: std::io::Error,
    },
}

impl LocalFileIndex {
    /// Skanuje lokalne pliki z manifestu.
    ///
    /// Dla każdego pliku w manifeście (managed + action=file) sprawdza
    /// czy plik istnieje lokalnie i oblicza jego SHA-256.
    pub fn scan_from_manifest(
        manifest: &NormalizedManifest,
        client_dir: &Path,
    ) -> Result<Self, FileIndexError> {
        let mut files = BTreeMap::new();

        for entry in &manifest.files {
            // Skanuj wszystkie pliki z manifestu (nie tylko managed),
            // żeby planner mógł podejmować decyzje o każdym
            let full_path = client_dir.join(&entry.path);

            if full_path.exists() && full_path.is_file() {
                let sha = sha256_file(&full_path).map_err(|e| FileIndexError::IoError {
                    path: entry.path.clone(),
                    source: e,
                })?;

                let metadata =
                    std::fs::metadata(&full_path).map_err(|e| FileIndexError::IoError {
                        path: entry.path.clone(),
                        source: e,
                    })?;

                files.insert(
                    entry.path.clone(),
                    LocalFileInfo {
                        sha256: sha,
                        size: metadata.len(),
                        exists: true,
                    },
                );
            } else {
                files.insert(
                    entry.path.clone(),
                    LocalFileInfo {
                        sha256: String::new(),
                        size: 0,
                        exists: false,
                    },
                );
            }
        }

        Ok(Self { files })
    }

    /// Skanuje WSZYSTKIE pliki w katalogu klienta (do repair / orphan detection).
    pub fn scan_full_directory(client_dir: &Path) -> Result<Self, FileIndexError> {
        let mut files = BTreeMap::new();

        if !client_dir.exists() {
            return Ok(Self { files });
        }

        fn walk_dir(
            base: &Path,
            current: &Path,
            files: &mut BTreeMap<String, LocalFileInfo>,
        ) -> Result<(), FileIndexError> {
            let entries = std::fs::read_dir(current).map_err(|e| FileIndexError::IoError {
                path: current.display().to_string(),
                source: e,
            })?;

            for entry in entries {
                let entry = entry.map_err(|e| FileIndexError::IoError {
                    path: current.display().to_string(),
                    source: e,
                })?;

                let path = entry.path();

                if path.is_dir() {
                    // Pomijaj katalogi .launcher (staging, state)
                    if let Some(name) = path.file_name().and_then(|n| n.to_str()) {
                        if name.starts_with('.') {
                            continue;
                        }
                    }
                    walk_dir(base, &path, files)?;
                } else if path.is_file() {
                    let rel = path
                        .strip_prefix(base)
                        .unwrap_or(&path)
                        .to_string_lossy()
                        .replace('\\', "/");

                    let sha = sha256_file(&path).map_err(|e| FileIndexError::IoError {
                        path: rel.clone(),
                        source: e,
                    })?;

                    let size = std::fs::metadata(&path).map(|m| m.len()).unwrap_or(0);

                    files.insert(
                        rel,
                        LocalFileInfo {
                            sha256: sha,
                            size,
                            exists: true,
                        },
                    );
                }
            }
            Ok(())
        }

        walk_dir(client_dir, client_dir, &mut files)?;
        Ok(Self { files })
    }

    /// Sprawdza czy plik istnieje w indeksie i czy hash się zgadza.
    pub fn matches_hash(&self, path: &str, expected_sha256: &str) -> bool {
        self.files
            .get(path)
            .map(|info| info.exists && info.sha256 == expected_sha256)
            .unwrap_or(false)
    }

    /// Zwraca info o pliku (jeśli istnieje w indeksie).
    pub fn get(&self, path: &str) -> Option<&LocalFileInfo> {
        self.files.get(path)
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
    fn test_scan_from_manifest_empty_dir() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        let index = LocalFileIndex::scan_from_manifest(&manifest, tmp.path()).expect("scan");

        // Pliki powinny być w indeksie, ale jako nieistniejące
        assert!(!index.files.is_empty());
        for info in index.files.values() {
            assert!(!info.exists);
            assert!(info.sha256.is_empty());
        }
    }

    #[test]
    fn test_scan_from_manifest_with_files() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        fs::write(tmp.path().join("a.txt"), b"hello").expect("write");
        fs::write(tmp.path().join("b.txt"), b"world").expect("write");

        let index = LocalFileIndex::scan_from_manifest(&manifest, tmp.path()).expect("scan");

        let a = index.get("a.txt").expect("a.txt");
        assert!(a.exists);
        assert_eq!(a.sha256.len(), 64);
        assert_eq!(a.size, 5);

        let b = index.get("b.txt").expect("b.txt");
        assert!(b.exists);
    }

    #[test]
    fn test_matches_hash() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        fs::write(tmp.path().join("a.txt"), b"hello").expect("write");
        fs::write(tmp.path().join("b.txt"), b"world").expect("write");

        let index = LocalFileIndex::scan_from_manifest(&manifest, tmp.path()).expect("scan");

        // SHA-256 of "hello"
        let hello_sha = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824";
        assert!(index.matches_hash("a.txt", hello_sha));
        assert!(!index.matches_hash("a.txt", "wrong_hash"));
        assert!(!index.matches_hash("nonexistent.txt", hello_sha));
    }

    #[test]
    fn test_scan_full_directory() {
        let tmp = tempfile::tempdir().expect("tmpdir");
        fs::create_dir_all(tmp.path().join("sub")).expect("mkdir");
        fs::write(tmp.path().join("file1.txt"), b"content1").expect("write");
        fs::write(tmp.path().join("sub/file2.lua"), b"content2").expect("write");

        // Utwórz ukryty katalog (powinien być pomijany)
        fs::create_dir_all(tmp.path().join(".launcher")).expect("mkdir");
        fs::write(tmp.path().join(".launcher/state.json"), b"state").expect("write");

        let index = LocalFileIndex::scan_full_directory(tmp.path()).expect("scan");

        assert!(index.get("file1.txt").is_some());
        assert!(index.get("sub/file2.lua").is_some());
        // .launcher powinien być pominięty
        assert!(index.get(".launcher/state.json").is_none());
    }
}
