//! UpdatePlan — wynik plannera update'u.
//!
//! Planner porównuje manifest z lokalnymi plikami i generuje
//! deterministyczny plan zmian: co pobrać, co podmienić, co usunąć, co zostawić.

use serde::{Deserialize, Serialize};

/// Plan aktualizacji wygenerowany przez planner.
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePlan {
    /// Pliki do pobrania (nowe lub zmienione hash).
    pub to_download: Vec<PlannedFileAction>,

    /// Pliki do podmianki (po pobraniu, staging → docelowy).
    pub to_replace: Vec<PlannedFileAction>,

    /// Pliki do usunięcia (action=delete w manifeście).
    pub to_delete: Vec<PlannedDeleteAction>,

    /// Pliki bez zmian (hash zgodny).
    pub to_keep: Vec<String>,

    /// Manifest version, na który planujemy update.
    pub target_manifest_version: String,

    /// Manifest ID.
    pub target_manifest_id: String,

    /// Czy plan jest pusty (brak zmian).
    pub is_up_to_date: bool,

    /// Łączny rozmiar do pobrania (bajty).
    pub total_download_bytes: u64,

    /// Liczba plików do zaktualizowania.
    pub files_to_update_count: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PlannedFileAction {
    /// Ścieżka względna pliku.
    pub path: String,

    /// Oczekiwany SHA-256 z manifestu.
    pub expected_sha256: String,

    /// Rozmiar pliku w bajtach.
    pub size: u64,

    /// URL do pobrania.
    pub url: String,

    /// Czy plik jest nowy (nie istniał lokalnie).
    pub is_new: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct PlannedDeleteAction {
    /// Ścieżka pliku do usunięcia.
    pub path: String,
}

impl UpdatePlan {
    /// Tworzy plan "nic do zrobienia".
    pub fn up_to_date(manifest_version: String, manifest_id: String) -> Self {
        Self {
            to_download: Vec::new(),
            to_replace: Vec::new(),
            to_delete: Vec::new(),
            to_keep: Vec::new(),
            target_manifest_version: manifest_version,
            target_manifest_id: manifest_id,
            is_up_to_date: true,
            total_download_bytes: 0,
            files_to_update_count: 0,
        }
    }

    /// Podsumowanie planu do logów.
    pub fn summary(&self) -> String {
        format!(
            "UpdatePlan: {} download, {} replace, {} delete, {} keep, {} bytes total, up_to_date={}",
            self.to_download.len(),
            self.to_replace.len(),
            self.to_delete.len(),
            self.to_keep.len(),
            self.total_download_bytes,
            self.is_up_to_date,
        )
    }
}
