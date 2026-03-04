//! Lokalny stan instalacji: InstalledState, UpdateTransaction, managedFilesIndex.
//!
//! Zapisywany do `.launcher/installed_state.json`.
//! Zapis atomowy: tmp → fsync → rename.

use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

// ─────────────────────────────────────────────
// installed_state.json
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct InstalledState {
    pub schema_version: String,
    pub install_id: String,
    pub channel: String,
    pub client_install_path: String,
    pub launcher_version: String,

    pub current_manifest_version: Option<String>,
    pub current_manifest_id: Option<String>,
    pub current_files_hash: Option<String>,

    pub last_successful_update_utc: Option<String>,
    pub last_update_attempt_utc: Option<String>,
    pub last_update_result: UpdateResult,

    pub last_error_code: Option<String>,
    pub last_error_message: Option<String>,

    pub last_api_base_url: String,

    #[serde(default = "default_true")]
    pub tls_enforced: bool,

    #[serde(default)]
    pub last_launcher_version_check_utc: Option<String>,

    #[serde(default)]
    pub last_known_server_manifest_version: Option<String>,

    #[serde(default)]
    pub last_token_request: Option<LastTokenRequestMeta>,

    pub update_transaction: UpdateTransaction,

    #[serde(default)]
    pub managed_files_index: BTreeMap<String, ManagedFileState>,
}

impl InstalledState {
    /// Tworzy minimalny stan dla świeżej instalacji.
    pub fn new_minimal(
        install_id: String,
        channel: String,
        client_install_path: String,
        launcher_version: String,
        api_base_url: String,
    ) -> Self {
        Self {
            schema_version: "1.0".to_string(),
            install_id,
            channel,
            client_install_path,
            launcher_version,
            current_manifest_version: None,
            current_manifest_id: None,
            current_files_hash: None,
            last_successful_update_utc: None,
            last_update_attempt_utc: None,
            last_update_result: UpdateResult::NeverRun,
            last_error_code: None,
            last_error_message: None,
            last_api_base_url: api_base_url,
            tls_enforced: true,
            last_launcher_version_check_utc: None,
            last_known_server_manifest_version: None,
            last_token_request: None,
            update_transaction: UpdateTransaction::idle(),
            managed_files_index: BTreeMap::new(),
        }
    }

    pub fn mark_error(
        &mut self,
        code: impl Into<String>,
        message: impl Into<String>,
        now_utc: String,
    ) {
        self.last_update_attempt_utc = Some(now_utc);
        self.last_update_result = UpdateResult::Failed;
        self.last_error_code = Some(code.into());
        self.last_error_message = Some(message.into());
    }

    pub fn clear_error(&mut self) {
        self.last_error_code = None;
        self.last_error_message = None;
    }

    pub fn mark_success(
        &mut self,
        manifest_version: String,
        manifest_id: String,
        files_hash: String,
        now_utc: String,
    ) {
        self.current_manifest_version = Some(manifest_version);
        self.current_manifest_id = Some(manifest_id);
        self.current_files_hash = Some(files_hash);
        self.last_successful_update_utc = Some(now_utc.clone());
        self.last_update_attempt_utc = Some(now_utc);
        self.last_update_result = UpdateResult::Success;
        self.clear_error();
        self.update_transaction.mark_idle();
    }
}

// ─────────────────────────────────────────────
// Metadane ostatniego requestu tokena (bez tokena!)
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct LastTokenRequestMeta {
    pub requested_at_utc: String,
    pub launcher_version: String,
    pub manifest_version: Option<String>,
    /// Pierwsze 8-12 znaków hasha (diagnostyka), NIGDY pełny token
    pub files_hash_prefix: Option<String>,
    pub result: TokenRequestResult,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum TokenRequestResult {
    #[default]
    Unknown,
    Success,
    Rejected,
    RateLimited,
    NetworkError,
}

// ─────────────────────────────────────────────
// UpdateTransaction — stan transakcji patchowania
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct UpdateTransaction {
    pub tx_id: String,
    pub status: UpdateTxStatus,

    pub target_manifest_version: Option<String>,
    pub target_manifest_id: Option<String>,

    pub started_at_utc: Option<String>,
    pub updated_files: Vec<String>,
    pub backup_files: Vec<String>,

    pub delete_planned: Vec<String>,
    pub delete_applied: Vec<String>,

    pub staging_path: Option<String>,

    #[serde(default = "default_true")]
    pub resume_supported: bool,
}

impl UpdateTransaction {
    pub fn idle() -> Self {
        Self {
            tx_id: String::new(),
            status: UpdateTxStatus::Idle,
            target_manifest_version: None,
            target_manifest_id: None,
            started_at_utc: None,
            updated_files: Vec::new(),
            backup_files: Vec::new(),
            delete_planned: Vec::new(),
            delete_applied: Vec::new(),
            staging_path: None,
            resume_supported: true,
        }
    }

    pub fn begin(
        &mut self,
        tx_id: String,
        manifest_version: String,
        manifest_id: String,
        now_utc: String,
        staging_path: String,
    ) {
        self.tx_id = tx_id;
        self.status = UpdateTxStatus::Preparing;
        self.target_manifest_version = Some(manifest_version);
        self.target_manifest_id = Some(manifest_id);
        self.started_at_utc = Some(now_utc);
        self.updated_files.clear();
        self.backup_files.clear();
        self.delete_planned.clear();
        self.delete_applied.clear();
        self.staging_path = Some(staging_path);
    }

    pub fn mark_idle(&mut self) {
        *self = Self::idle();
    }

    pub fn needs_recovery(&self) -> bool {
        !matches!(self.status, UpdateTxStatus::Idle)
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum UpdateTxStatus {
    #[default]
    Idle,
    Preparing,
    Downloading,
    Verifying,
    Applying,
    Finalizing,
    RollbackRequired,
    RollbackInProgress,
}

// ─────────────────────────────────────────────
// Lokalny indeks plików zarządzanych
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManagedFileState {
    pub sha256: String,
    pub size: u64,
    pub manifest_version: String,
    pub managed: bool,
    pub installed_at_utc: String,

    #[serde(default)]
    pub tags: Vec<String>,

    #[serde(default)]
    pub was_modified_locally: bool,
}

// ─────────────────────────────────────────────
// Wynik ostatniego update'u
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum UpdateResult {
    #[default]
    NeverRun,
    Success,
    Failed,
    Partial,
    RollbackSuccess,
    RollbackFailed,
}

fn default_true() -> bool {
    true
}

// ─────────────────────────────────────────────
// Testy
// ─────────────────────────────────────────────

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_new_minimal_state() {
        let state = InstalledState::new_minimal(
            "test-uuid".into(),
            "stable".into(),
            "/games/client".into(),
            "0.1.0".into(),
            "https://api.example.com/".into(),
        );
        assert_eq!(state.schema_version, "1.0");
        assert_eq!(state.last_update_result, UpdateResult::NeverRun);
        assert!(!state.update_transaction.needs_recovery());
        assert!(state.current_manifest_version.is_none());
    }

    #[test]
    fn test_mark_success() {
        let mut state = InstalledState::new_minimal(
            "uuid".into(),
            "stable".into(),
            "/c".into(),
            "0.1.0".into(),
            "https://x/".into(),
        );
        state.mark_success(
            "1.0.3".into(),
            "stable:1.0.3".into(),
            "abc123".into(),
            "2026-03-02T18:00:00Z".into(),
        );
        assert_eq!(state.last_update_result, UpdateResult::Success);
        assert_eq!(state.current_manifest_version.as_deref(), Some("1.0.3"));
        assert_eq!(state.current_files_hash.as_deref(), Some("abc123"));
        assert!(!state.update_transaction.needs_recovery());
    }

    #[test]
    fn test_mark_error() {
        let mut state = InstalledState::new_minimal(
            "uuid".into(),
            "stable".into(),
            "/c".into(),
            "0.1.0".into(),
            "https://x/".into(),
        );
        state.mark_error(
            "LCH_DOWNLOAD_FAILED",
            "timeout",
            "2026-03-02T18:00:00Z".into(),
        );
        assert_eq!(state.last_update_result, UpdateResult::Failed);
        assert_eq!(
            state.last_error_code.as_deref(),
            Some("LCH_DOWNLOAD_FAILED")
        );
    }

    #[test]
    fn test_transaction_needs_recovery() {
        let mut tx = UpdateTransaction::idle();
        assert!(!tx.needs_recovery());

        tx.begin(
            "tx1".into(),
            "1.0".into(),
            "s:1.0".into(),
            "now".into(),
            "/tmp".into(),
        );
        assert!(tx.needs_recovery());
        assert_eq!(tx.status, UpdateTxStatus::Preparing);

        tx.mark_idle();
        assert!(!tx.needs_recovery());
    }

    #[test]
    fn test_serialize_roundtrip() {
        let state = InstalledState::new_minimal(
            "uuid-1".into(),
            "test".into(),
            "/client".into(),
            "0.1.0".into(),
            "https://api/".into(),
        );
        let json = serde_json::to_string_pretty(&state).expect("serialize");
        let back: InstalledState = serde_json::from_str(&json).expect("deserialize");
        assert_eq!(back.install_id, "uuid-1");
        assert_eq!(back.channel, "test");
    }
}
