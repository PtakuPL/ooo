//! LR-030: Testy integracyjne — pełne scenariusze z fixture'ami (bez real HTTP).
//!
//! Testują flow: manifest → skan → plan → stage → apply bez real API.
//! Używają katalogów tymczasowych i fixture'ów JSON.

use std::collections::BTreeMap;
use std::fs;
use std::path::PathBuf;

use common_models::installed_state::{InstalledState, UpdateTxStatus};
use common_models::manifest::{parse_manifest_compat, NormalizedManifest};
use common_models::update_plan::UpdatePlan;

use launcher_core::file_index::LocalFileIndex;
use launcher_core::integrity::{compute_files_hash, sha256_bytes};
use launcher_core::patcher::{self, PatchContext};
use launcher_core::planner;
use launcher_core::repair;
use launcher_core::serverlist_sync;
use launcher_core::state;

// ─────────────────────────────────────────────
// Helper: tworzy manifest fixture w pamięci
// ─────────────────────────────────────────────

fn sample_manifest_json() -> String {
    r#"{
        "schemaVersion": "2",
        "manifestId": "test:1.0.0",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "channel": "test",
        "baseUrl": "https://cdn.example.com/files",
        "filesHashExpected": "placeholder",
        "files": [
            {
                "path": "modules/core.lua",
                "sha256": "PLACEHOLDER_CORE",
                "size": 100,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            },
            {
                "path": "data/config.json",
                "sha256": "PLACEHOLDER_CONFIG",
                "size": 50,
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            },
            {
                "path": "old/deprecated.txt",
                "action": "delete",
                "managed": true,
                "includeInFilesHash": false
            }
        ],
        "servers": [
            {
                "id": "srv1",
                "name": "Test Server",
                "host": "test.example.com",
                "port": 7171,
                "visible": true,
                "enabled": true,
                "priority": 1,
                "channel": "test"
            }
        ],
        "changelog": []
    }"#
    .to_string()
}

/// Tworzy pliki w katalogu klienta i aktualizuje SHA-256 w manifeście.
fn setup_client_files(
    client_dir: &PathBuf,
    files: &[(&str, &[u8])],
) -> NormalizedManifest {
    let mut json = sample_manifest_json();

    for (path, content) in files {
        let full_path = client_dir.join(path);
        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent).expect("mkdir");
        }
        fs::write(&full_path, content).expect("write file");

        // Podmień placeholder hash w manifeście
        let hash = sha256_bytes(content);
        let placeholder = match *path {
            "modules/core.lua" => "PLACEHOLDER_CORE",
            "data/config.json" => "PLACEHOLDER_CONFIG",
            _ => continue,
        };
        json = json.replace(placeholder, &hash);
    }

    parse_manifest_compat(&json).expect("parse manifest")
}

// ─────────────────────────────────────────────
// Scenariusz 1: Update — nowa instalacja (puste katalogi)
// ─────────────────────────────────────────────

#[test]
fn integration_fresh_install_generates_download_plan() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    // Manifest z dwoma plikami, ale klient jest pusty
    let json = sample_manifest_json()
        .replace("PLACEHOLDER_CORE", "abc123")
        .replace("PLACEHOLDER_CONFIG", "def456");

    let manifest = parse_manifest_compat(&json).expect("parse");

    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir).expect("scan");
    let plan = planner::build_update_plan(&manifest, &index).expect("plan");

    // Oba pliki powinny być do pobrania (nowa instalacja)
    assert!(!plan.is_up_to_date);
    assert_eq!(plan.to_download.len(), 2);
    assert_eq!(plan.to_delete.len(), 0); // Brak old/deprecated.txt na dysku
    assert!(plan.to_download.iter().any(|f| f.path == "modules/core.lua"));
    assert!(plan.to_download.iter().any(|f| f.path == "data/config.json"));
}

// ─────────────────────────────────────────────
// Scenariusz 2: Update — pliki są aktualne
// ─────────────────────────────────────────────

#[test]
fn integration_up_to_date_no_download() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core content 123"),
            ("data/config.json", b"config content 456"),
        ],
    );

    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir).expect("scan");
    let plan = planner::build_update_plan(&manifest, &index).expect("plan");

    // Pliki aktualne — plan powinien być pusty
    assert!(plan.is_up_to_date);
    assert_eq!(plan.to_download.len(), 0);
    assert_eq!(plan.to_keep.len(), 2);
}

// ─────────────────────────────────────────────
// Scenariusz 3: Update — jeden plik zmieniony
// ─────────────────────────────────────────────

#[test]
fn integration_one_file_changed_partial_update() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    // Utwórz pliki z poprawnymi hashami
    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core content 123"),
            ("data/config.json", b"config content 456"),
        ],
    );

    // Zmodyfikuj jeden plik — hash się zmieni
    fs::write(client_dir.join("modules/core.lua"), b"MODIFIED content").expect("write");

    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir).expect("scan");
    let plan = planner::build_update_plan(&manifest, &index).expect("plan");

    // Tylko core.lua powinien być do pobrania
    assert!(!plan.is_up_to_date);
    assert_eq!(plan.to_download.len(), 1);
    assert_eq!(plan.to_download[0].path, "modules/core.lua");
    assert_eq!(plan.to_keep.len(), 1); // config.json OK
}

// ─────────────────────────────────────────────
// Scenariusz 4: Patcher — stage + apply + verify
// ─────────────────────────────────────────────

#[test]
fn integration_stage_apply_verify_flow() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    let launcher_dir = tmp.path().join(".launcher");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let ctx = PatchContext::new(&client_dir, &launcher_dir, "test-tx-int");
    ctx.init_dirs().expect("init dirs");

    // Symuluj "pobrany" plik
    let file_data = b"new module content for integration test";
    let expected_sha = sha256_bytes(file_data);

    // Stage
    patcher::stage_file(&ctx, "modules/core.lua", file_data, &expected_sha).expect("stage");
    assert!(ctx.staging_dir.join("modules/core.lua").exists());

    // Backup (nie ma oryginalnego — powinien przejść)
    patcher::backup_file(&ctx, "modules/core.lua").expect("backup");

    // Apply
    patcher::apply_staged_file(&ctx, "modules/core.lua").expect("apply");
    assert!(client_dir.join("modules/core.lua").exists());

    let content = fs::read_to_string(client_dir.join("modules/core.lua")).expect("read");
    assert_eq!(content, "new module content for integration test");

    // Cleanup
    ctx.cleanup().expect("cleanup");
}

// ─────────────────────────────────────────────
// Scenariusz 5: Hash mismatch — odrzucenie pliku
// ─────────────────────────────────────────────

#[test]
fn integration_hash_mismatch_rejects_file() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    let launcher_dir = tmp.path().join(".launcher");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let ctx = PatchContext::new(&client_dir, &launcher_dir, "test-tx-bad");
    ctx.init_dirs().expect("init dirs");

    let file_data = b"corrupted content";
    let wrong_sha = "0000000000000000000000000000000000000000000000000000000000000000";

    // Stage z złym hashem powinien być odrzucony
    let result = patcher::stage_file(&ctx, "modules/bad.lua", file_data, wrong_sha);
    assert!(result.is_err());

    match result {
        Err(patcher::PatcherError::HashMismatch { path, .. }) => {
            assert_eq!(path, "modules/bad.lua");
        }
        _ => panic!("Oczekiwany HashMismatch"),
    }

    // Plik nie powinien być w staging
    assert!(!ctx.staging_dir.join("modules/bad.lua").exists());
}

// ─────────────────────────────────────────────
// Scenariusz 6: Rollback po błędnym update
// ─────────────────────────────────────────────

#[test]
fn integration_rollback_restores_original_files() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    let launcher_dir = tmp.path().join(".launcher");
    fs::create_dir_all(&client_dir).expect("mkdir");

    // Utwórz oryginalny plik
    fs::create_dir_all(client_dir.join("modules")).expect("mkdir");
    fs::write(client_dir.join("modules/core.lua"), b"ORIGINAL").expect("write");

    let ctx = PatchContext::new(&client_dir, &launcher_dir, "test-tx-rollback");
    ctx.init_dirs().expect("init dirs");

    // Backup oryginalnego
    patcher::backup_file(&ctx, "modules/core.lua").expect("backup");

    // Nadpisz nowymi danymi
    let new_data = b"NEW VERSION";
    let new_sha = sha256_bytes(new_data);
    patcher::stage_file(&ctx, "modules/core.lua", new_data, &new_sha).expect("stage");
    patcher::apply_staged_file(&ctx, "modules/core.lua").expect("apply");

    // Potwierdź że nadpisany
    let content = fs::read_to_string(client_dir.join("modules/core.lua")).expect("read");
    assert_eq!(content, "NEW VERSION");

    // Przygotuj state do rollback
    let mut installed = InstalledState::new_minimal(
        "test-id".into(),
        "test".into(),
        client_dir.to_string_lossy().to_string(),
        "0.1.0".into(),
        "https://api/".into(),
    );
    installed.update_transaction.tx_id = "test-tx-rollback".into();
    installed.update_transaction.status = UpdateTxStatus::Applying;
    installed
        .update_transaction
        .updated_files
        .push("modules/core.lua".into());

    state::save_state(&installed, &ctx.state_path).expect("save state");

    // Rollback!
    patcher::rollback(&ctx, &mut installed).expect("rollback");

    // Plik powinien wrócić do oryginału
    let content = fs::read_to_string(client_dir.join("modules/core.lua")).expect("read");
    assert_eq!(content, "ORIGINAL");
    assert_eq!(installed.update_transaction.status, UpdateTxStatus::Idle);
}

// ─────────────────────────────────────────────
// Scenariusz 7: Recovery detection
// ─────────────────────────────────────────────

#[test]
fn integration_recovery_detection_after_crash() {
    let state_idle = InstalledState::new_minimal(
        "test".into(),
        "stable".into(),
        "/c".into(),
        "0.1.0".into(),
        "https://api/".into(),
    );

    assert!(!patcher::check_recovery_needed(&state_idle));

    // Symuluj przerwany update
    let mut state_crashed = state_idle;
    state_crashed.update_transaction.status = UpdateTxStatus::Downloading;
    state_crashed.update_transaction.tx_id = "crashed-tx".into();

    assert!(patcher::check_recovery_needed(&state_crashed));

    // Symuluj stan po rozpoczęciu apply
    let mut state_applying = InstalledState::new_minimal(
        "test2".into(),
        "stable".into(),
        "/c".into(),
        "0.1.0".into(),
        "https://api/".into(),
    );
    state_applying.update_transaction.status = UpdateTxStatus::Applying;
    assert!(patcher::check_recovery_needed(&state_applying));
}

// ─────────────────────────────────────────────
// Scenariusz 8: State persistence roundtrip
// ─────────────────────────────────────────────

#[test]
fn integration_state_save_load_roundtrip() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let state_path = tmp.path().join("installed_state.json");

    let mut original = InstalledState::new_minimal(
        "int-test-id".into(),
        "stable".into(),
        "/opt/game/client".into(),
        "0.2.0".into(),
        "https://api.example.com".into(),
    );
    original.mark_success(
        "1.0.3".into(),
        "stable:1.0.3".into(),
        "abcdef1234".into(),
        "2026-03-03T12:00:00Z".into(),
    );

    // Save
    state::save_state(&original, &state_path).expect("save");
    assert!(state_path.exists());

    // Load
    let loaded = state::load_state(&state_path).expect("load");
    assert_eq!(loaded.install_id, "int-test-id");
    assert_eq!(loaded.channel, "stable");
    assert_eq!(
        loaded.current_manifest_version.as_deref(),
        Some("1.0.3")
    );
    assert_eq!(
        loaded.current_files_hash.as_deref(),
        Some("abcdef1234")
    );
    assert_eq!(loaded.update_transaction.status, UpdateTxStatus::Idle);
}

// ─────────────────────────────────────────────
// Scenariusz 9: filesHash — compute i verify
// ─────────────────────────────────────────────

#[test]
fn integration_files_hash_consistent() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core for hash test"),
            ("data/config.json", b"config for hash test"),
        ],
    );

    // Oblicz hash dwukrotnie — wynik powinien być identyczny (determinizm)
    let hash1 = compute_files_hash(&manifest, &client_dir).expect("hash1");
    let hash2 = compute_files_hash(&manifest, &client_dir).expect("hash2");
    assert_eq!(hash1, hash2);

    // Hash powinien się zmienić po modyfikacji pliku
    fs::write(
        client_dir.join("modules/core.lua"),
        b"MODIFIED core content",
    )
    .expect("write");

    let hash3 = compute_files_hash(&manifest, &client_dir).expect("hash3");
    assert_ne!(hash1, hash3);
}

// ─────────────────────────────────────────────
// Scenariusz 10: Repair — diagnoza korumpowanej instalacji
// ─────────────────────────────────────────────

#[test]
fn integration_repair_diagnoses_corrupted_installation() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    // Utwórz poprawne pliki i manifest
    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core content 123"),
            ("data/config.json", b"config content 456"),
        ],
    );

    // Skorumpuj jeden plik
    fs::write(client_dir.join("modules/core.lua"), b"CORRUPTED!!").expect("write");

    let (diag, plan) = repair::diagnose_installation(&manifest, &client_dir).expect("diagnose");

    assert_eq!(diag.corrupted_files.len(), 1);
    assert_eq!(diag.corrupted_files[0], "modules/core.lua");
    assert_eq!(diag.ok_files.len(), 1);
    assert_eq!(diag.ok_files[0], "data/config.json");
    assert_eq!(diag.missing_files.len(), 0);

    // Plan naprawy powinien pobierać skorumpowany plik
    assert!(!plan.is_up_to_date);
    assert!(plan
        .to_download
        .iter()
        .any(|f| f.path == "modules/core.lua"));
}

// ─────────────────────────────────────────────
// Scenariusz 11: Repair — brak pliku
// ─────────────────────────────────────────────

#[test]
fn integration_repair_detects_missing_file() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core content 123"),
            ("data/config.json", b"config content 456"),
        ],
    );

    // Usuń jeden plik
    fs::remove_file(client_dir.join("data/config.json")).expect("remove");

    let (diag, _) = repair::diagnose_installation(&manifest, &client_dir).expect("diagnose");

    assert_eq!(diag.missing_files.len(), 1);
    assert_eq!(diag.missing_files[0], "data/config.json");
    assert_eq!(diag.ok_files.len(), 1);
}

// ─────────────────────────────────────────────
// Scenariusz 12: Serverlist sync
// ─────────────────────────────────────────────

#[test]
fn integration_serverlist_sync_generates_files() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    let manifest = setup_client_files(
        &client_dir,
        &[("modules/core.lua", b"core")],
    );

    // Sync serverlist Lua
    let lua_path = client_dir.join("init_serverlist.lua");
    serverlist_sync::sync_serverlist(&manifest.servers, &lua_path).expect("sync lua");
    assert!(lua_path.exists());

    let lua_content = fs::read_to_string(&lua_path).expect("read lua");
    assert!(lua_content.contains("MANAGED_SERVER_LIST"));
    assert!(lua_content.contains("Test Server"));
    assert!(lua_content.contains("test.example.com"));

    // Sync serverlist JSON
    let json_path = client_dir.join("serverlist.json");
    serverlist_sync::sync_serverlist_json(&manifest.servers, &json_path).expect("sync json");
    assert!(json_path.exists());

    let json_content = fs::read_to_string(&json_path).expect("read json");
    assert!(json_content.contains("Test Server"));
}

// ─────────────────────────────────────────────
// Scenariusz 13: Delete action w manifeście
// ─────────────────────────────────────────────

#[test]
fn integration_delete_action_deletes_file() {
    let tmp = tempfile::tempdir().expect("tmpdir");
    let client_dir = tmp.path().join("client");
    fs::create_dir_all(&client_dir).expect("mkdir");

    // Utwórz poprawne pliki
    let manifest = setup_client_files(
        &client_dir,
        &[
            ("modules/core.lua", b"core content 123"),
            ("data/config.json", b"config content 456"),
        ],
    );

    // Utwórz plik do usunięcia (jest w manifeście jako action=delete)
    fs::create_dir_all(client_dir.join("old")).expect("mkdir");
    fs::write(client_dir.join("old/deprecated.txt"), b"old stuff").expect("write");

    let index = LocalFileIndex::scan_from_manifest(&manifest, &client_dir).expect("scan");
    let plan = planner::build_update_plan(&manifest, &index).expect("plan");

    // Pliki aktualne, ale old/deprecated.txt powinien być do usunięcia
    assert_eq!(plan.to_download.len(), 0);
    assert_eq!(plan.to_delete.len(), 1);
    assert_eq!(plan.to_delete[0].path, "old/deprecated.txt");
}
