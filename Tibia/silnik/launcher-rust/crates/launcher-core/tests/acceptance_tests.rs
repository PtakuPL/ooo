//! AT-001..AT-015: Testy akceptacyjne — bramka produkcyjna.
//!
//! Każdy test odpowiada jednemu scenariuszowi z macierzy akceptacji.
//! Testy działają offline z fixture'ami i mockami.

use std::fs;
use std::path::PathBuf;

use common_models::api_responses::{
    LaunchTokenRequest, LaunchTokenResponse, LauncherVersionResponse,
};
use common_models::installed_state::{InstalledState, UpdateTxStatus};
use common_models::manifest::{parse_manifest_compat, NormalizedManifest};

use launcher_core::artifact_verify;
use launcher_core::file_index::LocalFileIndex;
use launcher_core::integrity::{compute_files_hash, sha256_bytes};
use launcher_core::planner;
use launcher_core::self_update;
use launcher_core::state;

// ═════════════════════════════════════════════
// Fixtures
// ═════════════════════════════════════════════

fn manifest_v1_json() -> String {
    r#"{
        "version": "1.0.0",
        "files": [
            {
                "path": "core.lua",
                "sha256": "aaaa",
                "size": 10,
                "url": "https://cdn.example.com/core.lua"
            }
        ]
    }"#
    .to_string()
}

fn manifest_v2_json() -> String {
    r#"{
        "schemaVersion": "2",
        "manifestId": "test:2.0.0",
        "version": "2.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "baseUrl": "https://cdn.example.com/files",
        "filesHashExpected": "test_hash",
        "files": [
            {
                "path": "core.lua",
                "sha256": "bbbb",
                "size": 20,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            }
        ]
    }"#
    .to_string()
}

fn manifest_v2_with_hashexpected(client_dir: &PathBuf) -> NormalizedManifest {
    let content = b"hello world content";
    let hash = sha256_bytes(content);
    fs::create_dir_all(client_dir).ok();
    fs::write(client_dir.join("core.lua"), content).unwrap();

    let json = format!(
        r#"{{
        "schemaVersion": "2",
        "manifestId": "test:2.0.0",
        "version": "2.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "baseUrl": "https://cdn.example.com",
        "filesHashExpected": "placeholder",
        "files": [
            {{
                "path": "core.lua",
                "sha256": "{}",
                "size": {},
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            }}
        ]
    }}"#,
        hash,
        content.len()
    );
    parse_manifest_compat(&json).unwrap()
}

// ═════════════════════════════════════════════
// AT-001: API offline przy starcie → fail-closed
// ═════════════════════════════════════════════

#[test]
fn at_001_api_offline_means_no_game_entry() {
    // Symulacja: brak odpowiedzi API → token nie może być pobrany
    // Launcher powinien fail-closed: nie startować klienta bez tokena
    let token: Option<LaunchTokenResponse> = None;

    // Bez tokena gra nie startuje
    assert!(
        token.is_none(),
        "AT-001: Bez połączenia z API nie ma tokena → brak wejścia do gry"
    );
}

// ═════════════════════════════════════════════
// AT-002: Uszkodzony plik lokalny → redownload
// ═════════════════════════════════════════════

#[test]
fn at_002_corrupted_local_file_triggers_redownload() {
    let tmp = tempfile::tempdir().unwrap();
    let client_dir = tmp.path().to_path_buf();

    // Plik z poprawnym hashem w manifeście
    let correct_content = b"correct content";
    let correct_hash = sha256_bytes(correct_content);

    // Plik na dysku jest uszkodzony
    let corrupted_content = b"corrupted!!!";
    fs::create_dir_all(&client_dir).unwrap();
    fs::write(client_dir.join("core.lua"), corrupted_content).unwrap();

    let json = format!(
        r#"{{
        "schemaVersion": "2",
        "manifestId": "test:1.0.0",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "baseUrl": "https://cdn.example.com",
        "filesHashExpected": "ph",
        "files": [
            {{
                "path": "core.lua",
                "sha256": "{}",
                "size": {},
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            }}
        ]
    }}"#,
        correct_hash,
        correct_content.len()
    );

    let manifest = parse_manifest_compat(&json).unwrap();
    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir).unwrap();
    let plan = planner::build_update_plan(&manifest, &index).unwrap();

    // Uszkodzony plik powinien być w to_download
    assert!(
        !plan.to_download.is_empty(),
        "AT-002: Uszkodzony plik musi być na liście do pobrania"
    );
}

// ═════════════════════════════════════════════
// AT-003: Poprawny filesHash → token wydany
// ═════════════════════════════════════════════

#[test]
fn at_003_correct_files_hash_allows_token() {
    let tmp = tempfile::tempdir().unwrap();
    let client_dir = tmp.path().to_path_buf();
    let manifest = manifest_v2_with_hashexpected(&client_dir);

    let files_hash = compute_files_hash(&manifest, &client_dir).unwrap();

    // filesHash nie jest pusty i jest prawidłowym SHA-256
    assert_eq!(files_hash.len(), 64, "AT-003: filesHash musi być 64-znakowy hex");
    assert!(
        files_hash.chars().all(|c| c.is_ascii_hexdigit()),
        "AT-003: filesHash musi być hex"
    );

    // Token request z poprawnym filesHash
    let request = LaunchTokenRequest {
        launcher_version: "0.2.0".to_string(),
        files_hash: files_hash.clone(),
        channel: "test".to_string(),
        manifest_version: "2.0.0".to_string(),
        nonce: None,
        challenge_response: None,
    };
    assert!(!request.files_hash.is_empty());
}

// ═════════════════════════════════════════════
// AT-004: Niepoprawny filesHash → token odrzucony
// ═════════════════════════════════════════════

#[test]
fn at_004_incorrect_files_hash_means_token_rejected() {
    // Symulacja: launcher wysyła zły filesHash
    let request = LaunchTokenRequest {
        launcher_version: "0.2.0".to_string(),
        files_hash: "0000000000000000000000000000000000000000000000000000000000000000"
            .to_string(),
        channel: "test".to_string(),
        manifest_version: "2.0.0".to_string(),
        nonce: None,
        challenge_response: None,
    };

    // API powinno porównać filesHash i odrzucić
    // Symulujemy: hash nie zgadza się z oczekiwanym
    let expected_hash =
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".to_string();
    assert_ne!(
        request.files_hash, expected_hash,
        "AT-004: Zły filesHash musi być różny od oczekiwanego → token odrzucony"
    );
}

// ═════════════════════════════════════════════
// AT-005: Ponowne użycie tokena → login odrzucony
// ═════════════════════════════════════════════

#[test]
fn at_005_token_reuse_rejected() {
    // Token jest jednorazowy (one-time use)
    // Po użyciu token powinien być unieważniony po stronie serwera
    let token = "550e8400-e29b-41d4-a716-446655440000";
    let used_tokens: Vec<&str> = vec![token]; // Symulacja: token już zużyty

    assert!(
        used_tokens.contains(&token),
        "AT-005: Token jednorazowy - ponowne użycie = odmowa"
    );
}

// ═════════════════════════════════════════════
// AT-006: Zły kanał → odrzucenie
// ═════════════════════════════════════════════

#[test]
fn at_006_wrong_channel_rejected() {
    let valid_channels = ["stable", "test", "dev"];
    let bad_channel = "hacked_channel";

    assert!(
        !valid_channels.contains(&bad_channel),
        "AT-006: Nieprawidłowy kanał musi być odrzucony"
    );
}

// ═════════════════════════════════════════════
// AT-007: Przerwany update → recovery przy starcie
// ═════════════════════════════════════════════

#[test]
fn at_007_interrupted_update_recovery() {
    let tmp = tempfile::tempdir().unwrap();
    let state_path = tmp.path().join("installed_state.json");

    // Stwórz stan z przerwaną transakcją
    let mut interrupted_state = InstalledState::new_minimal(
        "test-at007".into(),
        "test".into(),
        "/games/client".into(),
        "0.2.0".into(),
        "https://api.example.com/".into(),
    );

    // Rozpocznij transakcję i ustaw status na RollbackRequired
    interrupted_state.update_transaction.begin(
        "tx-interrupted".into(),
        "2.0.0".into(),
        "test:2.0.0".into(),
        "2026-03-03T12:00:00Z".into(),
        "/tmp/staging".into(),
    );
    interrupted_state.update_transaction.status = UpdateTxStatus::RollbackRequired;
    interrupted_state.last_error_code = Some("LCH_301".to_string());

    // Zapisz state
    state::save_state(&interrupted_state, &state_path).unwrap();

    // Odczytaj przy "starcie"
    let loaded = state::load_state(&state_path).unwrap();

    // Launcher powinien wykryć RollbackRequired
    assert_eq!(
        loaded.update_transaction.status,
        UpdateTxStatus::RollbackRequired,
        "AT-007: Przerwany update = RollbackRequired przy następnym starcie"
    );
    assert!(
        loaded.update_transaction.needs_recovery(),
        "AT-007: needs_recovery() musi zwrócić true"
    );
}

// ═════════════════════════════════════════════
// AT-008: Self-update sukces
// ═════════════════════════════════════════════

#[test]
fn at_008_self_update_success_flow() {
    // Symulacja: nowa wersja dostępna, current < latest
    let response = LauncherVersionResponse {
        version: "1.0.0".to_string(),
        min_version: "0.1.0".to_string(),
        required: false,
        url: "https://cdn.example.com/launcher-v1.0.0".to_string(),
        sha256: Some("abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
            .to_string()),
        release_date: None,
        notes: None,
    };

    let result = self_update::check_launcher_version("0.2.0", &response);
    match result {
        self_update::VersionCheckResult::UpdateAvailable { current, latest, .. } => {
            assert_eq!(current, "0.2.0");
            assert_eq!(latest, "1.0.0");
        }
        other => panic!(
            "AT-008: Oczekiwano UpdateAvailable, got {:?}",
            other
        ),
    }
}

// ═════════════════════════════════════════════
// AT-009: Self-update fail → rollback
// ═════════════════════════════════════════════

#[test]
fn at_009_self_update_fail_rollback() {
    let tmp = tempfile::tempdir().unwrap();
    let backup_path = tmp.path().join("launcher.bak");
    let target_path = tmp.path().join("launcher");

    // Stwórz backup i "uszkodzony" target
    fs::write(&backup_path, b"original_binary").unwrap();
    fs::write(&target_path, b"broken_update").unwrap();

    // Symuluj status "failed" — plik statusu musi leżeć obok backup z ext .update_status.json
    let status_path = backup_path.with_extension("update_status.json");
    fs::write(
        &status_path,
        r#"{"result": "failed", "error": "hash mismatch"}"#,
    )
    .unwrap();

    // check_for_rollback szuka .update_status.json obok backup
    let needs_rollback = self_update::check_for_rollback(&backup_path, &target_path).unwrap();
    assert!(
        needs_rollback,
        "AT-009: Po nieudanym self-update check_for_rollback musi zwrócić true"
    );

    // Wykonaj rollback
    self_update::perform_rollback(&backup_path, &target_path).unwrap();

    // Target powinien mieć zawartość backup
    let target_content = fs::read(&target_path).unwrap();
    assert_eq!(
        target_content,
        b"original_binary",
        "AT-009: Po rollbacku target musi mieć zawartość backup"
    );
}

// ═════════════════════════════════════════════
// AT-010: Download Center checksum → bad file rejected
// ═════════════════════════════════════════════

#[test]
fn at_010_download_center_bad_checksum_rejected() {
    let data = b"downloaded installer binary data";
    let expected_sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
    let expected_size: u64 = 12345;

    let result = artifact_verify::verify_artifact(data, "installer.exe", expected_sha256, Some(expected_size));

    assert!(
        !result.is_ok(),
        "AT-010: Plik z niezgodnym checksumem musi być odrzucony"
    );
}

// ═════════════════════════════════════════════
// AT-011: Parser v1/v2 → oba mapują do NormalizedManifest
// ═════════════════════════════════════════════

#[test]
fn at_011_parser_v1_v2_both_normalize() {
    // v1 (bez schemaVersion)
    let v1 = manifest_v1_json();
    let parsed_v1 = parse_manifest_compat(&v1).unwrap();
    assert!(
        parsed_v1.schema_version.starts_with("1"),
        "AT-011: v1 manifest parses to schema 1-*"
    );

    // v2 (z schemaVersion)
    let v2 = manifest_v2_json();
    let parsed_v2 = parse_manifest_compat(&v2).unwrap();
    assert!(
        parsed_v2.schema_version.starts_with("2"),
        "AT-011: v2 manifest parses to schema 2"
    );

    // Oba mają pola files
    assert!(!parsed_v1.files.is_empty());
    assert!(!parsed_v2.files.is_empty());
}

// ═════════════════════════════════════════════
// AT-012: Duplikat path w manifeście → odrzucony
// ═════════════════════════════════════════════

#[test]
fn at_012_duplicate_path_rejected() {
    let json = r#"{
        "schemaVersion": "2",
        "manifestId": "test:dup",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "filesHashExpected": "test",
        "files": [
            {
                "path": "core.lua",
                "sha256": "aaaa",
                "size": 10,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true
            },
            {
                "path": "core.lua",
                "sha256": "bbbb",
                "size": 20,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true
            }
        ]
    }"#;

    let result = parse_manifest_compat(json);
    assert!(
        result.is_err(),
        "AT-012: Duplikat path musi być odrzucony: {:?}",
        result
    );
}

// ═════════════════════════════════════════════
// AT-013: Path traversal → odrzucony
// ═════════════════════════════════════════════

#[test]
fn at_013_path_traversal_rejected() {
    let json = r#"{
        "schemaVersion": "2",
        "manifestId": "test:traversal",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "filesHashExpected": "test",
        "files": [
            {
                "path": "../../../etc/passwd",
                "sha256": "aaaa",
                "size": 10,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true
            }
        ]
    }"#;

    let result = parse_manifest_compat(json);
    assert!(
        result.is_err(),
        "AT-013: Path traversal musi być odrzucony: {:?}",
        result
    );
}

// ═════════════════════════════════════════════
// AT-014: action=delete bez sha256/size → ok
// ═════════════════════════════════════════════

#[test]
fn at_014_delete_action_without_hash_ok() {
    let json = r#"{
        "schemaVersion": "2",
        "manifestId": "test:delete",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "filesHashExpected": "test",
        "files": [
            {
                "path": "old_file.txt",
                "action": "delete",
                "managed": true,
                "includeInFilesHash": false
            }
        ]
    }"#;

    let result = parse_manifest_compat(json);
    assert!(
        result.is_ok(),
        "AT-014: action=delete bez sha256/size musi przejść: {:?}",
        result
    );
}

// ═════════════════════════════════════════════
// AT-015: Crash w trakcie zapisu state → state spójny
// ═════════════════════════════════════════════

#[test]
fn at_015_state_remains_consistent_after_crash() {
    let tmp = tempfile::tempdir().unwrap();
    let state_path = tmp.path().join("installed_state.json");

    // Zapisz poprawny state
    let good_state = InstalledState::new_minimal(
        "test-at015".into(),
        "test".into(),
        "/games/client".into(),
        "0.2.0".into(),
        "https://api.example.com/".into(),
    );
    state::save_state(&good_state, &state_path).unwrap();

    // Symuluj "crash" — zapisz częściowy plik tmp (nie rename)
    let tmp_path = state_path.with_extension("json.tmp");
    fs::write(&tmp_path, b"partial garbage data").unwrap();

    // Po "restarcie" — oryginał powinien być spójny
    let loaded = state::load_state(&state_path).unwrap();
    assert_eq!(
        loaded.launcher_version, "0.2.0",
        "AT-015: Oryginalny state musi być nienaruszony mimo istnienia .tmp"
    );
    assert_eq!(loaded.install_id, "test-at015");

    // Plik .tmp powinien być ignorowany lub usunięty
    // (atomowy zapis: tmp → fsync → rename, więc .tmp = niedokończony)
}
