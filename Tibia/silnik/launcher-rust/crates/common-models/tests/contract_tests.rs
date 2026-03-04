//! LR-010: Testy kontraktowe API — walidują zgodność modeli serde z zamrożonymi kontraktami.
//!
//! Każdy test deserializuje fixture JSON (z docs/contracts/) i sprawdza,
//! że wszystkie wymagane pola są obecne i mają poprawne typy.
//!
//! Cel: wykryć regresje kompatybilności serializacji/deserializacji.

// Ścieżka do fixture'ów kontraktowych
const FIXTURES_DIR: &str = concat!(
    env!("CARGO_MANIFEST_DIR"),
    "/../../tests/contracts/fixtures"
);

// ─────────────────────────────────────────
// Test 1: launcher-version.php response
// ─────────────────────────────────────────

#[test]
fn contract_launcher_version_response_deserializes() {
    let json = std::fs::read_to_string(format!("{}/launcher_version_response.json", FIXTURES_DIR))
        .expect("fixture file");

    let resp: common_models::api_responses::LauncherVersionResponse =
        serde_json::from_str(&json).expect("deserialize LauncherVersionResponse");

    // Wymagane pola wg kontraktu LR-001
    assert_eq!(resp.version, "0.2.0");
    assert_eq!(resp.min_version, "0.1.0");
    assert!(resp.required);
    assert!(!resp.url.is_empty());
    assert!(!resp.sha256.as_deref().unwrap_or("").is_empty());

    // Opcjonalne pola
    assert_eq!(resp.release_date.as_deref(), Some("2026-03-02"));
    assert!(resp.notes.is_some());
}

#[test]
fn contract_launcher_version_response_required_fields_only() {
    // Minimalna odpowiedź z samymi wymaganymi polami
    let json = r#"{
        "version": "1.0.0",
        "minVersion": "0.9.0",
        "required": false,
        "url": "https://example.com/dl/",
        "sha256": "deadbeef"
    }"#;

    let resp: common_models::api_responses::LauncherVersionResponse =
        serde_json::from_str(json).expect("deserialize minimal");

    assert_eq!(resp.version, "1.0.0");
    assert!(!resp.required);
    assert_eq!(resp.release_date, None);
    assert_eq!(resp.notes, None);
}

#[test]
fn contract_launcher_version_response_without_sha256() {
    // PHP może nie zwracać sha256 (backward compat) — Rust musi to obsłużyć
    let json = r#"{
        "version": "1.0.0",
        "minVersion": "0.9.0",
        "required": false,
        "url": "https://example.com/dl/",
        "notes": "Test release"
    }"#;

    let resp: common_models::api_responses::LauncherVersionResponse =
        serde_json::from_str(json).expect("deserialize without sha256");

    assert_eq!(resp.version, "1.0.0");
    assert_eq!(resp.sha256, None);
    assert_eq!(resp.notes.as_deref(), Some("Test release"));
}

// ─────────────────────────────────────────
// Test 2: launcher-version response serialization roundtrip
// ─────────────────────────────────────────

#[test]
fn contract_launcher_version_response_roundtrip() {
    let json = std::fs::read_to_string(format!("{}/launcher_version_response.json", FIXTURES_DIR))
        .expect("fixture file");

    let resp: common_models::api_responses::LauncherVersionResponse =
        serde_json::from_str(&json).expect("deserialize");

    // Serialize → deserialize roundtrip
    let serialized = serde_json::to_string(&resp).expect("serialize");
    let resp2: common_models::api_responses::LauncherVersionResponse =
        serde_json::from_str(&serialized).expect("deserialize roundtrip");

    assert_eq!(resp.version, resp2.version);
    assert_eq!(resp.min_version, resp2.min_version);
    assert_eq!(resp.required, resp2.required);
    assert_eq!(resp.url, resp2.url);
    assert_eq!(resp.sha256, resp2.sha256);
}

// ─────────────────────────────────────────
// Test 3: launch-token.php response
// ─────────────────────────────────────────

#[test]
fn contract_launch_token_response_deserializes() {
    let json = std::fs::read_to_string(format!("{}/launch_token_response.json", FIXTURES_DIR))
        .expect("fixture file");

    let resp: common_models::api_responses::LaunchTokenResponse =
        serde_json::from_str(&json).expect("deserialize LaunchTokenResponse");

    // Wymagane pola wg kontraktu LR-003
    assert!(!resp.token.is_empty());
    assert_eq!(resp.expires_in_seconds, 300);

    // Token powinien wyglądać jak UUID
    assert!(resp.token.contains('-'));
}

// ─────────────────────────────────────────
// Test 4: launch-token.php error response
// ─────────────────────────────────────────

#[test]
fn contract_launch_token_error_response_deserializes() {
    let json =
        std::fs::read_to_string(format!("{}/launch_token_error_response.json", FIXTURES_DIR))
            .expect("fixture file");

    let resp: common_models::api_responses::LaunchTokenErrorResponse =
        serde_json::from_str(&json).expect("deserialize LaunchTokenErrorResponse");

    assert_eq!(resp.error, "files_hash_mismatch");
    assert!(!resp.message.is_empty());
}

// ─────────────────────────────────────────
// Test 5: launch-token.php request
// ─────────────────────────────────────────

#[test]
fn contract_launch_token_request_serializes_to_camel_case() {
    let req = common_models::api_responses::LaunchTokenRequest {
        launcher_version: "0.2.0".into(),
        files_hash: "abcdef".into(),
        channel: "stable".into(),
        manifest_version: "1.0.3".into(),
        nonce: None,
        challenge_response: None,
    };

    let json = serde_json::to_value(&req).expect("serialize request");

    // Kontrakt wymaga camelCase w JSON
    assert!(
        json.get("launcherVersion").is_some(),
        "camelCase: launcherVersion"
    );
    assert!(json.get("filesHash").is_some(), "camelCase: filesHash");
    assert!(json.get("channel").is_some(), "camelCase: channel");
    assert!(
        json.get("manifestVersion").is_some(),
        "camelCase: manifestVersion"
    );

    // Nie powinno być snake_case
    assert!(json.get("launcher_version").is_none(), "no snake_case");
    assert!(json.get("files_hash").is_none(), "no snake_case");
    assert!(json.get("manifest_version").is_none(), "no snake_case");
}

#[test]
fn contract_launch_token_request_deserializes_from_fixture() {
    let json = std::fs::read_to_string(format!("{}/launch_token_request.json", FIXTURES_DIR))
        .expect("fixture file");

    let req: common_models::api_responses::LaunchTokenRequest =
        serde_json::from_str(&json).expect("deserialize LaunchTokenRequest");

    assert_eq!(req.launcher_version, "0.2.0");
    assert_eq!(req.channel, "stable");
    assert_eq!(req.manifest_version, "1.0.3");
    assert!(!req.files_hash.is_empty());
}

// ─────────────────────────────────────────
// Test 6: installed_state.json full schema
// ─────────────────────────────────────────

#[test]
fn contract_installed_state_deserializes_full() {
    let json = std::fs::read_to_string(format!("{}/installed_state_full.json", FIXTURES_DIR))
        .expect("fixture file");

    let state: common_models::installed_state::InstalledState =
        serde_json::from_str(&json).expect("deserialize InstalledState");

    // Top-level wymagane pola wg kontraktu LR-006
    assert_eq!(state.schema_version, "1.0");
    assert!(!state.install_id.is_empty());
    assert_eq!(state.channel, "stable");
    assert!(!state.client_install_path.is_empty());
    assert_eq!(state.launcher_version, "0.2.0");
    assert_eq!(state.current_manifest_version.as_deref(), Some("1.0.3"));
    assert_eq!(state.current_manifest_id.as_deref(), Some("stable:1.0.3"));
    assert!(state.current_files_hash.is_some());
    assert!(state.tls_enforced);

    // updateTransaction
    assert_eq!(
        state.update_transaction.status,
        common_models::installed_state::UpdateTxStatus::Idle
    );
    assert!(state.update_transaction.updated_files.is_empty());

    // managedFilesIndex
    assert!(state.managed_files_index.contains_key("modules/game.lua"));
    let file_meta = &state.managed_files_index["modules/game.lua"];
    assert_eq!(file_meta.sha256, "abc123def456");
    assert_eq!(file_meta.size, 1024);
    assert!(file_meta.managed);
}

#[test]
fn contract_installed_state_roundtrip() {
    let json = std::fs::read_to_string(format!("{}/installed_state_full.json", FIXTURES_DIR))
        .expect("fixture file");

    let state: common_models::installed_state::InstalledState =
        serde_json::from_str(&json).expect("deserialize");

    let serialized = serde_json::to_string_pretty(&state).expect("serialize");
    let state2: common_models::installed_state::InstalledState =
        serde_json::from_str(&serialized).expect("deserialize roundtrip");

    assert_eq!(state.schema_version, state2.schema_version);
    assert_eq!(state.install_id, state2.install_id);
    assert_eq!(state.channel, state2.channel);
    assert_eq!(
        state.current_manifest_version,
        state2.current_manifest_version
    );
    assert_eq!(
        state.update_transaction.status,
        state2.update_transaction.status
    );
    assert_eq!(
        state.managed_files_index.len(),
        state2.managed_files_index.len()
    );
}

// ─────────────────────────────────────────
// Test 7: installed_state — updateTransaction statusy
// ─────────────────────────────────────────

#[test]
fn contract_update_tx_status_serde_names() {
    use common_models::installed_state::UpdateTxStatus;

    // Kontrakt LR-006 definiuje status jako snake_case w JSON
    let cases = vec![
        (UpdateTxStatus::Idle, "idle"),
        (UpdateTxStatus::Preparing, "preparing"),
        (UpdateTxStatus::Downloading, "downloading"),
        (UpdateTxStatus::Verifying, "verifying"),
        (UpdateTxStatus::Applying, "applying"),
        (UpdateTxStatus::Finalizing, "finalizing"),
        (UpdateTxStatus::RollbackRequired, "rollback_required"),
        (UpdateTxStatus::RollbackInProgress, "rollback_in_progress"),
    ];

    for (variant, expected_str) in cases {
        let json = serde_json::to_value(&variant).expect("serialize status");
        assert_eq!(
            json.as_str().unwrap(),
            expected_str,
            "Oczekiwany JSON dla {:?}: {:?}",
            variant,
            expected_str
        );

        // Roundtrip
        let deserialized: UpdateTxStatus =
            serde_json::from_value(json).expect("deserialize status");
        assert_eq!(deserialized, variant);
    }
}

// ─────────────────────────────────────────
// Test 8: installed_state — lastUpdateResult
// ─────────────────────────────────────────

#[test]
fn contract_update_result_serde_names() {
    use common_models::installed_state::UpdateResult;

    let cases = vec![
        (UpdateResult::NeverRun, "never_run"),
        (UpdateResult::Success, "success"),
        (UpdateResult::Failed, "failed"),
        (UpdateResult::Partial, "partial"),
        (UpdateResult::RollbackSuccess, "rollback_success"),
        (UpdateResult::RollbackFailed, "rollback_failed"),
    ];

    for (variant, expected_str) in cases {
        let json = serde_json::to_value(&variant).expect("serialize");
        assert_eq!(
            json.as_str().unwrap(),
            expected_str,
            "Oczekiwany JSON dla {:?}: {:?}",
            variant,
            expected_str
        );
    }
}

// ─────────────────────────────────────────
// Test 9: manifest v1 fixture — kontrakt LR-002
// ─────────────────────────────────────────

#[test]
fn contract_manifest_v1_parses_to_normalized() {
    let fixture = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/fixtures/manifest_v1.json"
    );
    let json = std::fs::read_to_string(fixture).expect("fixture file");

    let manifest =
        common_models::manifest::parse_manifest_compat(&json).expect("parse manifest v1");

    // Znormalizowany manifest powinien mieć wymagane pola
    assert_eq!(manifest.schema_version, "1");
    assert!(!manifest.version.is_empty());
    assert!(!manifest.channel.is_empty());
    assert!(!manifest.files.is_empty());
}

// ─────────────────────────────────────────
// Test 10: manifest v2 fixture — kontrakt LR-005
// ─────────────────────────────────────────

#[test]
fn contract_manifest_v2_parses_to_normalized() {
    let fixture = concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/tests/fixtures/manifest_v2.json"
    );
    let json = std::fs::read_to_string(fixture).expect("fixture file");

    let manifest =
        common_models::manifest::parse_manifest_compat(&json).expect("parse manifest v2");

    // V2 specyficzne pola wg LR-005
    assert_eq!(manifest.schema_version, "2");
    assert!(manifest.files_hash_expected.is_some());
    assert!(!manifest.version.is_empty());
}

// ─────────────────────────────────────────
// Test 11: error codes — LR-007 — pełne pokrycie
// ─────────────────────────────────────────

#[test]
fn contract_error_codes_have_lch_prefix() {
    use common_models::error_codes::LauncherErrorCode;

    let all_codes = vec![
        LauncherErrorCode::ManifestFetchFailed,
        LauncherErrorCode::ManifestParseFailed,
        LauncherErrorCode::ManifestSchemaUnsupported,
        LauncherErrorCode::ManifestSignatureInvalid,
        LauncherErrorCode::ManifestPathTraversal,
        LauncherErrorCode::ManifestDuplicatePath,
        LauncherErrorCode::DownloadFailed,
        LauncherErrorCode::FileHashMismatch,
        LauncherErrorCode::PatchApplyFailed,
        LauncherErrorCode::RollbackFailed,
        LauncherErrorCode::RollbackSuccess,
        LauncherErrorCode::FilesHashComputeFailed,
        LauncherErrorCode::TokenRequestFailed,
        LauncherErrorCode::TokenRejected,
        LauncherErrorCode::TokenRateLimited,
        LauncherErrorCode::ClientStartFailed,
        LauncherErrorCode::ClientNotFound,
        LauncherErrorCode::TlsRequired,
        LauncherErrorCode::StateCorrupted,
        LauncherErrorCode::LauncherUpdateRequired,
        LauncherErrorCode::StagingCleanupFailed,
    ];

    for code in &all_codes {
        let s = code.as_str();
        assert!(
            s.starts_with("LCH_"),
            "Kod {:?} powinien zaczynać się od LCH_: {}",
            code,
            s
        );
        assert!(
            !code.user_message().is_empty(),
            "Kod {:?} powinien mieć user_message",
            code
        );
    }

    // 21 kodów wg error-codes.md
    assert_eq!(all_codes.len(), 21, "Oczekiwane 21 kodów LCH_*");
}

// ─────────────────────────────────────────
// Test 12: manifest file entry — overwrite/delete policies
// ─────────────────────────────────────────

#[test]
fn contract_manifest_overwrite_delete_policies_serde() {
    use common_models::manifest::{DeletePolicy, OverwritePolicy};

    // OverwritePolicy (kontrakt LR-005/LR-008)
    let cases_ow = vec![
        (OverwritePolicy::Always, "always"),
        (OverwritePolicy::IfHashDiffers, "if_hash_differs"),
        (OverwritePolicy::Never, "never"),
        (OverwritePolicy::PreserveUser, "preserve_user"),
    ];

    for (variant, expected) in cases_ow {
        let json = serde_json::to_value(&variant).expect("serialize");
        assert_eq!(json.as_str().unwrap(), expected);
    }

    // DeletePolicy
    let cases_del = vec![
        (DeletePolicy::Allow, "allow"),
        (DeletePolicy::Protect, "protect"),
        (DeletePolicy::OrphanCleanup, "orphan_cleanup"),
    ];

    for (variant, expected) in cases_del {
        let json = serde_json::to_value(&variant).expect("serialize");
        assert_eq!(json.as_str().unwrap(), expected);
    }
}

// ─────────────────────────────────────────
// Test 13: manifest file actions serde
// ─────────────────────────────────────────

#[test]
fn contract_manifest_file_actions_serde() {
    use common_models::manifest::ManifestFileAction;

    let cases = vec![
        (ManifestFileAction::File, "file"),
        (ManifestFileAction::Delete, "delete"),
        (ManifestFileAction::Mkdir, "mkdir"),
        (ManifestFileAction::Noop, "noop"),
    ];

    for (variant, expected) in cases {
        let json = serde_json::to_value(&variant).expect("serialize");
        assert_eq!(json.as_str().unwrap(), expected);
    }
}
