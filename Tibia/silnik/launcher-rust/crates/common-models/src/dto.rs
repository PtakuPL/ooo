//! LR-079: Warstwa DTO statusów dla Tauri.
//!
//! Frontend dostaje tylko status/komunikaty/progres — nigdy surowe struktury manifestu
//! ani pełny `InstalledState`. Każda struktura jest `Serialize` (Tauri command return),
//! a testy weryfikują kontrakt JSON.

use serde::{Deserialize, Serialize};

// ─────────────────────────────────────────────
// Ogólny status launchera
// ─────────────────────────────────────────────

/// Tryb widoku UI — Tauri wybiera ekran na podstawie tego.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum LauncherPhase {
    /// Sprawdzanie wersji launchera / klienta.
    Checking,
    /// Aktualizacja w toku.
    Updating,
    /// Gotowy do startu gry.
    Ready,
    /// Naprawa instalacji.
    Repairing,
    /// Błąd krytyczny — wymaga akcji użytkownika.
    Error,
    /// Wymaga aktualizacji samego launchera.
    LauncherUpdateRequired,
}

/// Pełny status zwracany do UI w jednym DTO.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LauncherStatusDto {
    pub phase: LauncherPhase,
    pub launcher_version: String,
    pub channel: String,

    /// Wersja manifestu klienta (jeśli znana).
    pub client_version: Option<String>,

    /// Czy klient jest aktualny.
    pub client_up_to_date: bool,

    /// Informacja o błędzie (jeśli `phase == Error`).
    pub error: Option<ErrorInfoDto>,

    /// Informacja o wymaganej aktualizacji launchera (jeśli phase == LauncherUpdateRequired).
    pub launcher_update: Option<LauncherUpdateDto>,
}

impl LauncherStatusDto {
    pub fn ready(launcher_version: String, channel: String, client_version: String) -> Self {
        Self {
            phase: LauncherPhase::Ready,
            launcher_version,
            channel,
            client_version: Some(client_version),
            client_up_to_date: true,
            error: None,
            launcher_update: None,
        }
    }

    pub fn checking(launcher_version: String, channel: String) -> Self {
        Self {
            phase: LauncherPhase::Checking,
            launcher_version,
            channel,
            client_version: None,
            client_up_to_date: false,
            error: None,
            launcher_update: None,
        }
    }

    pub fn with_error(launcher_version: String, channel: String, error: ErrorInfoDto) -> Self {
        Self {
            phase: LauncherPhase::Error,
            launcher_version,
            channel,
            client_version: None,
            client_up_to_date: false,
            error: Some(error),
            launcher_update: None,
        }
    }
}

// ─────────────────────────────────────────────
// Postęp aktualizacji
// ─────────────────────────────────────────────

/// Postęp aktualizacji (emit do frontend jako event lub polling).
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdateProgressDto {
    /// Etap aktualizacji widoczny dla użytkownika.
    pub stage: UpdateStage,

    /// Nazwa aktualnie przetwarzanego pliku (opcjonalna).
    pub current_file: Option<String>,

    /// Pliki przetworzone / planowane.
    pub files_done: u32,
    pub files_total: u32,

    /// Bajty pobrane / planowane.
    pub bytes_done: u64,
    pub bytes_total: u64,

    /// Procent postępu 0–100.
    pub percent: u8,

    /// Szacowany czas (sekundy). None = brak szacunku.
    pub eta_seconds: Option<u32>,
}

/// Etap aktualizacji widoczny w UI.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum UpdateStage {
    /// Sprawdzanie manifestu.
    CheckingManifest,
    /// Skanowanie lokalnych plików.
    ScanningFiles,
    /// Pobieranie plików.
    Downloading,
    /// Weryfikacja pobranych plików.
    Verifying,
    /// Aplikowanie zmian (staging → docelowy).
    Applying,
    /// Finalizacja (zapis state, czyszczenie).
    Finalizing,
    /// Zakończone.
    Done,
}

impl UpdateProgressDto {
    /// Szybki helper — „dopiero startujemy".
    pub fn starting(files_total: u32, bytes_total: u64) -> Self {
        Self {
            stage: UpdateStage::CheckingManifest,
            current_file: None,
            files_done: 0,
            files_total,
            bytes_done: 0,
            bytes_total,
            percent: 0,
            eta_seconds: None,
        }
    }

    /// Przelicza `percent` na podstawie `bytes_done / bytes_total`.
    pub fn recalculate_percent(&mut self) {
        if self.bytes_total == 0 {
            self.percent = 100;
        } else {
            self.percent =
                ((self.bytes_done as f64 / self.bytes_total as f64) * 100.0).min(100.0) as u8;
        }
    }
}

// ─────────────────────────────────────────────
// Błędy (user-facing)
// ─────────────────────────────────────────────

/// Informacja o błędzie do wyświetlenia w UI.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ErrorInfoDto {
    /// Kod LCH_* (do logów i diagnostyki).
    pub code: String,
    /// Wiadomość PL dla użytkownika.
    pub user_message: String,
    /// Czy można ponowić (retry button w UI).
    pub retryable: bool,
    /// Ile razy już próbowano.
    pub attempt: u32,
}

impl ErrorInfoDto {
    pub fn from_code(code: &crate::error_codes::LauncherErrorCode, attempt: u32) -> Self {
        let retryable = matches!(
            code,
            crate::error_codes::LauncherErrorCode::ManifestFetchFailed
                | crate::error_codes::LauncherErrorCode::DownloadFailed
                | crate::error_codes::LauncherErrorCode::TokenRequestFailed
                | crate::error_codes::LauncherErrorCode::TokenRateLimited
                | crate::error_codes::LauncherErrorCode::ClientStartFailed
        );

        Self {
            code: code.as_str().to_string(),
            user_message: code.user_message().to_string(),
            retryable,
            attempt,
        }
    }

    pub fn generic(code: String, message: String, retryable: bool) -> Self {
        Self {
            code,
            user_message: message,
            retryable,
            attempt: 0,
        }
    }
}

// ─────────────────────────────────────────────
// Launcher self-update info
// ─────────────────────────────────────────────

/// Informacja o wymaganej aktualizacji launchera.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LauncherUpdateDto {
    /// Nowa dostępna wersja.
    pub new_version: String,
    /// Aktualna wersja zainstalowana.
    pub current_version: String,
    /// Czy wymagana (blokuje uruchomienie gry).
    pub required: bool,
    /// Informacje o wydaniu (release notes).
    pub notes: Option<String>,
    /// URL do pobrania (jeśli manual).
    pub download_url: Option<String>,
}

impl LauncherUpdateDto {
    pub fn from_api_response(
        resp: &crate::api_responses::LauncherVersionResponse,
        current_version: &str,
    ) -> Self {
        Self {
            new_version: resp.version.clone(),
            current_version: current_version.to_string(),
            required: resp.required,
            notes: resp.notes.clone(),
            download_url: Some(resp.url.clone()),
        }
    }
}

// ─────────────────────────────────────────────
// Diagnostyka naprawy
// ─────────────────────────────────────────────

/// Wynik diagnostyki instalacji do UI.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct RepairDiagnosticsDto {
    /// Pliki uszkodzone (hash niezgodny).
    pub corrupted_count: u32,
    /// Pliki brakujące.
    pub missing_count: u32,
    /// Pliki poprawne.
    pub ok_count: u32,
    /// Łączny rozmiar do pobrania przy naprawie (bajty).
    pub repair_download_bytes: u64,
    /// Lista uszkodzonych plików (ścieżki).
    pub corrupted_files: Vec<String>,
    /// Lista brakujących plików (ścieżki).
    pub missing_files: Vec<String>,
}

// ─────────────────────────────────────────────
// Status instalacji (uproszczony widok state)
// ─────────────────────────────────────────────

/// Podsumowanie stanu instalacji — uproszczony widok `InstalledState`.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstallationSummaryDto {
    /// ID instalacji.
    pub install_id: String,
    /// Kanał (stable/test/dev).
    pub channel: String,
    /// Wersja manifestu klienta (jeśli jest).
    pub client_version: Option<String>,
    /// Hash plików (jeśli policzony).
    pub files_hash: Option<String>,
    /// Ostatni wynik aktualizacji.
    pub last_update_result: String,
    /// Ostatni udany update (UTC).
    pub last_successful_update: Option<String>,
    /// Czy wymaga recovery (transakcja w trakcie).
    pub needs_recovery: bool,
    /// Kod ostatniego błędu.
    pub last_error_code: Option<String>,
    /// Wiadomość dla użytkownika.
    pub last_error_message: Option<String>,
}

impl InstallationSummaryDto {
    pub fn from_state(state: &crate::installed_state::InstalledState) -> Self {
        Self {
            install_id: state.install_id.clone(),
            channel: state.channel.clone(),
            client_version: state.current_manifest_version.clone(),
            files_hash: state.current_files_hash.clone(),
            last_update_result: serde_json::to_value(&state.last_update_result)
                .ok()
                .and_then(|v| v.as_str().map(String::from))
                .unwrap_or_else(|| format!("{:?}", state.last_update_result)),
            last_successful_update: state.last_successful_update_utc.clone(),
            needs_recovery: state.update_transaction.needs_recovery(),
            last_error_code: state.last_error_code.clone(),
            last_error_message: state.last_error_message.clone(),
        }
    }
}

// ─────────────────────────────────────────────
// Plan aktualizacji (podsumowanie)
// ─────────────────────────────────────────────

/// Podsumowanie planu aktualizacji do UI.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdatePlanSummaryDto {
    /// Czy klient jest aktualny (nic do zrobienia).
    pub up_to_date: bool,
    /// Wersja docelowa.
    pub target_version: String,
    /// Pliki do pobrania.
    pub files_to_download: u32,
    /// Pliki do usunięcia.
    pub files_to_delete: u32,
    /// Pliki bez zmian.
    pub files_unchanged: u32,
    /// Łączny rozmiar pobierania (bajty).
    pub download_bytes: u64,
}

impl UpdatePlanSummaryDto {
    pub fn from_plan(plan: &crate::update_plan::UpdatePlan) -> Self {
        Self {
            up_to_date: plan.is_up_to_date,
            target_version: plan.target_manifest_version.clone(),
            files_to_download: plan.to_download.len() as u32,
            files_to_delete: plan.to_delete.len() as u32,
            files_unchanged: plan.to_keep.len() as u32,
            download_bytes: plan.total_download_bytes,
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
    fn test_launcher_status_dto_serialize() {
        let dto = LauncherStatusDto::ready("0.1.0".into(), "stable".into(), "1.2.3".into());
        let json = serde_json::to_value(&dto).unwrap();
        assert_eq!(json["phase"], "ready");
        assert_eq!(json["launcherVersion"], "0.1.0");
        assert_eq!(json["clientVersion"], "1.2.3");
        assert_eq!(json["clientUpToDate"], true);
        assert!(json["error"].is_null());
    }

    #[test]
    fn test_update_progress_percent() {
        let mut p = UpdateProgressDto::starting(10, 1000);
        p.bytes_done = 500;
        p.recalculate_percent();
        assert_eq!(p.percent, 50);

        p.bytes_done = 1000;
        p.recalculate_percent();
        assert_eq!(p.percent, 100);
    }

    #[test]
    fn test_update_progress_zero_total() {
        let mut p = UpdateProgressDto::starting(0, 0);
        p.recalculate_percent();
        assert_eq!(p.percent, 100);
    }

    #[test]
    fn test_error_info_from_code() {
        let err =
            ErrorInfoDto::from_code(&crate::error_codes::LauncherErrorCode::DownloadFailed, 3);
        assert_eq!(err.code, "LCH_DOWNLOAD_FAILED");
        assert!(err.retryable);
        assert_eq!(err.attempt, 3);
        assert!(!err.user_message.is_empty());
    }

    #[test]
    fn test_error_non_retryable() {
        let err = ErrorInfoDto::from_code(
            &crate::error_codes::LauncherErrorCode::ManifestPathTraversal,
            0,
        );
        assert!(!err.retryable);
    }

    #[test]
    fn test_launcher_update_dto_serialize() {
        let dto = LauncherUpdateDto {
            new_version: "1.0.0".into(),
            current_version: "0.9.0".into(),
            required: true,
            notes: Some("Important fix".into()),
            download_url: Some("https://cdn/launcher.exe".into()),
        };
        let json = serde_json::to_value(&dto).unwrap();
        assert_eq!(json["newVersion"], "1.0.0");
        assert_eq!(json["required"], true);
        assert_eq!(json["downloadUrl"], "https://cdn/launcher.exe");
    }

    #[test]
    fn test_repair_diagnostics_dto_serialize() {
        let dto = RepairDiagnosticsDto {
            corrupted_count: 2,
            missing_count: 1,
            ok_count: 10,
            repair_download_bytes: 50_000,
            corrupted_files: vec!["data/a.bin".into()],
            missing_files: vec!["data/b.bin".into()],
        };
        let json = serde_json::to_value(&dto).unwrap();
        assert_eq!(json["corruptedCount"], 2);
        assert_eq!(json["repairDownloadBytes"], 50_000);
    }

    #[test]
    fn test_update_plan_summary_dto() {
        let plan = crate::update_plan::UpdatePlan {
            to_download: vec![],
            to_replace: vec![],
            to_delete: vec![],
            to_keep: vec!["a.bin".into(), "b.bin".into()],
            target_manifest_version: "1.0.0".into(),
            target_manifest_id: "stable:1.0.0".into(),
            is_up_to_date: true,
            total_download_bytes: 0,
            files_to_update_count: 0,
        };
        let dto = UpdatePlanSummaryDto::from_plan(&plan);
        assert!(dto.up_to_date);
        assert_eq!(dto.files_unchanged, 2);
        assert_eq!(dto.target_version, "1.0.0");
    }

    #[test]
    fn test_installation_summary_from_state() {
        let state = crate::installed_state::InstalledState::new_minimal(
            "test-uuid".into(),
            "stable".into(),
            "/games/client".into(),
            "0.1.0".into(),
            "https://api.example.com/".into(),
        );
        let dto = InstallationSummaryDto::from_state(&state);
        assert_eq!(dto.install_id, "test-uuid");
        assert_eq!(dto.channel, "stable");
        assert!(dto.client_version.is_none());
        assert!(!dto.needs_recovery);
        assert_eq!(dto.last_update_result, "never_run");
    }

    #[test]
    fn test_update_stages_serde() {
        let stages = vec![
            UpdateStage::CheckingManifest,
            UpdateStage::ScanningFiles,
            UpdateStage::Downloading,
            UpdateStage::Verifying,
            UpdateStage::Applying,
            UpdateStage::Finalizing,
            UpdateStage::Done,
        ];
        for stage in &stages {
            let json = serde_json::to_value(stage).unwrap();
            let back: UpdateStage = serde_json::from_value(json.clone()).unwrap();
            assert_eq!(&back, stage);
        }
    }

    #[test]
    fn test_launcher_phases_serde() {
        let phases = vec![
            LauncherPhase::Checking,
            LauncherPhase::Updating,
            LauncherPhase::Ready,
            LauncherPhase::Repairing,
            LauncherPhase::Error,
            LauncherPhase::LauncherUpdateRequired,
        ];
        for phase in &phases {
            let json = serde_json::to_value(phase).unwrap();
            let back: LauncherPhase = serde_json::from_value(json.clone()).unwrap();
            assert_eq!(&back, phase);
        }
    }

    #[test]
    fn test_status_dto_with_error() {
        let err = ErrorInfoDto::generic("LCH_CUSTOM".into(), "Something broke".into(), false);
        let dto = LauncherStatusDto::with_error("0.1.0".into(), "test".into(), err);
        let json = serde_json::to_value(&dto).unwrap();
        assert_eq!(json["phase"], "error");
        assert_eq!(json["error"]["code"], "LCH_CUSTOM");
        assert_eq!(json["error"]["retryable"], false);
    }
}
