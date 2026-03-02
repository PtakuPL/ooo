//! LR-028: Tryb naprawy instalacji.
//!
//! Pełny skan plików zarządzanych, redownload niezgodnych,
//! odbudowa managedFilesIndex, ponowne przeliczenie filesHash.

use std::path::Path;

use common_models::manifest::NormalizedManifest;
use common_models::update_plan::{PlannedFileAction, UpdatePlan};

use crate::file_index::LocalFileIndex;
use crate::planner;

/// Wynik diagnostyki naprawy.
#[derive(Debug, Clone)]
pub struct RepairDiagnostics {
    /// Pliki z niezgodnym hashem.
    pub corrupted_files: Vec<String>,
    /// Pliki brakujące.
    pub missing_files: Vec<String>,
    /// Pliki orphan (nie w manifeście, ale w katalogu).
    pub orphan_files: Vec<String>,
    /// Pliki OK.
    pub ok_files: Vec<String>,
    /// Łączna ilość do pobrania.
    pub total_repair_bytes: u64,
}

/// Skanuje instalację i generuje raport diagnostyczny + plan naprawy.
///
/// Zwraca (diagnostyka, plan_update) — plan update można potem użyć
/// z patcherem, żeby naprawić pliki.
pub fn diagnose_installation(
    manifest: &NormalizedManifest,
    client_dir: &Path,
) -> Result<(RepairDiagnostics, UpdatePlan), RepairError> {
    tracing::info!("Diagnoza instalacji: {}", client_dir.display());

    // Pełny skan z manifestu
    let index = LocalFileIndex::scan_from_manifest(manifest, client_dir)
        .map_err(|e| RepairError::ScanError(e.to_string()))?;

    let mut diag = RepairDiagnostics {
        corrupted_files: Vec::new(),
        missing_files: Vec::new(),
        orphan_files: Vec::new(),
        ok_files: Vec::new(),
        total_repair_bytes: 0,
    };

    for entry in &manifest.files {
        if !entry.managed {
            continue;
        }
        if entry.action != common_models::manifest::ManifestFileAction::File {
            continue;
        }

        let expected_sha = entry.sha256.as_deref().unwrap_or("");

        match index.get(&entry.path) {
            Some(info) if info.exists => {
                if info.sha256 == expected_sha {
                    diag.ok_files.push(entry.path.clone());
                } else {
                    diag.corrupted_files.push(entry.path.clone());
                    diag.total_repair_bytes += entry.size.unwrap_or(0);
                }
            }
            _ => {
                diag.missing_files.push(entry.path.clone());
                diag.total_repair_bytes += entry.size.unwrap_or(0);
            }
        }
    }

    // Opcjonalnie: skan orphan files
    if let Ok(full_index) = LocalFileIndex::scan_full_directory(client_dir) {
        for (path, _) in &full_index.files {
            let in_manifest = manifest.files.iter().any(|f| &f.path == path);
            if !in_manifest {
                diag.orphan_files.push(path.clone());
            }
        }
    }

    // Generuj plan naprawy (używa standardowego plannera)
    let plan = planner::build_update_plan(manifest, &index)
        .map_err(|e| RepairError::PlanError(e.to_string()))?;

    tracing::info!(
        "Diagnoza: {} OK, {} uszkodzonych, {} brakujących, {} orphan, {} B do naprawy",
        diag.ok_files.len(),
        diag.corrupted_files.len(),
        diag.missing_files.len(),
        diag.orphan_files.len(),
        diag.total_repair_bytes,
    );

    Ok((diag, plan))
}

/// Błędy naprawy.
#[derive(Debug, thiserror::Error)]
pub enum RepairError {
    #[error("Scan error: {0}")]
    ScanError(String),

    #[error("Plan error: {0}")]
    PlanError(String),
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
    fn test_diagnose_empty_dir() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        let (diag, plan) = diagnose_installation(&manifest, tmp.path()).expect("diagnose");

        assert!(diag.ok_files.is_empty());
        assert_eq!(diag.missing_files.len(), manifest.files.len());
        assert!(!plan.is_up_to_date);
    }

    #[test]
    fn test_diagnose_with_corrupted_file() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        // Utwórz plik z błędną treścią
        fs::write(tmp.path().join("a.txt"), b"wrong content").expect("write");

        let (diag, _plan) = diagnose_installation(&manifest, tmp.path()).expect("diagnose");

        assert!(diag.corrupted_files.contains(&"a.txt".to_string()));
        assert!(diag.missing_files.contains(&"b.txt".to_string()));
    }

    #[test]
    fn test_diagnose_orphan_detection() {
        let json = include_str!("../tests/fixtures/manifest_v1_minimal.json");
        let manifest = parse_manifest_compat(json).expect("parse");

        let tmp = tempfile::tempdir().expect("tmpdir");
        // Utwórz plik nie-manifestowy
        fs::write(tmp.path().join("orphan.txt"), b"orphan").expect("write");

        let (diag, _plan) = diagnose_installation(&manifest, tmp.path()).expect("diagnose");

        assert!(diag.orphan_files.contains(&"orphan.txt".to_string()));
    }
}
