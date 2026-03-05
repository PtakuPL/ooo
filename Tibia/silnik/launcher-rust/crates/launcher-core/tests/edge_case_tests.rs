//! Testy edge-case: filesHash, walidacja, grace period.
//!
//! Uzupełnienie luk zidentyfikowanych w audycie:
//! - filesHash deterministyczność i porządek sortowania
//! - walidacja URL, semver, channel, SHA-256
//! - grace period: akceptacja previous+current manifestu

use common_models::manifest::parse_manifest_compat;
use common_models::validation::{
    is_files_hash_acceptable, is_grace_period_active, validate_channel, validate_semver,
    validate_sha256_hex, validate_url,
};
use launcher_core::integrity::{compute_files_hash, sha256_bytes};
use std::fs;

// ═════════════════════════════════════════════
// filesHash — deterministyczność i sortowanie
// ═════════════════════════════════════════════

#[test]
fn files_hash_is_deterministic_across_calls() {
    let tmp = tempfile::tempdir().unwrap();
    let content_a = b"file content alpha";
    let content_b = b"file content beta";
    fs::write(tmp.path().join("alpha.lua"), content_a).unwrap();
    fs::write(tmp.path().join("beta.lua"), content_b).unwrap();

    let hash_a = sha256_bytes(content_a);
    let hash_b = sha256_bytes(content_b);

    let json = format!(
        r#"{{
        "schemaVersion": "2",
        "manifestId": "test:det",
        "version": "1.0.0",
        "releaseDate": "2026-03-03",
        "generatedAtUtc": "2026-03-03T00:00:00Z",
        "channel": "test",
        "baseUrl": "https://cdn.example.com",
        "filesHashExpected": "placeholder",
        "files": [
            {{
                "path": "beta.lua",
                "sha256": "{}",
                "size": {},
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            }},
            {{
                "path": "alpha.lua",
                "sha256": "{}",
                "size": {},
                "action": "file",
                "managed": true,
                "includeInFilesHash": true,
                "overwritePolicy": "always"
            }}
        ]
    }}"#,
        hash_b,
        content_b.len(),
        hash_a,
        content_a.len()
    );

    let manifest = parse_manifest_compat(&json).unwrap();

    // Wywołaj compute_files_hash 3 razy — wynik musi być identyczny
    let h1 = compute_files_hash(&manifest, tmp.path()).unwrap();
    let h2 = compute_files_hash(&manifest, tmp.path()).unwrap();
    let h3 = compute_files_hash(&manifest, tmp.path()).unwrap();

    assert_eq!(h1, h2, "filesHash musi być deterministyczny");
    assert_eq!(h2, h3, "filesHash musi być deterministyczny");
}

#[test]
fn files_hash_sorted_by_path_not_by_declaration_order() {
    let tmp = tempfile::tempdir().unwrap();
    let content = b"same content";
    let hash = sha256_bytes(content);

    fs::write(tmp.path().join("alpha.lua"), content).unwrap();
    fs::write(tmp.path().join("beta.lua"), content).unwrap();

    // Manifest 1: alpha przed beta
    let json1 = format!(
        r#"{{
        "schemaVersion": "2", "manifestId": "t:1", "version": "1.0.0",
        "releaseDate": "2026-03-03", "generatedAtUtc": "2026-03-03T00:00:00Z", "channel": "test",
        "filesHashExpected": "x",
        "files": [
            {{"path": "alpha.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}},
            {{"path": "beta.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}}
        ]
    }}"#,
        hash = hash,
        size = content.len()
    );

    // Manifest 2: beta przed alpha (odwrócona kolejność deklaracji)
    let json2 = format!(
        r#"{{
        "schemaVersion": "2", "manifestId": "t:1", "version": "1.0.0",
        "releaseDate": "2026-03-03", "generatedAtUtc": "2026-03-03T00:00:00Z", "channel": "test",
        "filesHashExpected": "x",
        "files": [
            {{"path": "beta.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}},
            {{"path": "alpha.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}}
        ]
    }}"#,
        hash = hash,
        size = content.len()
    );

    let m1 = parse_manifest_compat(&json1).unwrap();
    let m2 = parse_manifest_compat(&json2).unwrap();

    let h1 = compute_files_hash(&m1, tmp.path()).unwrap();
    let h2 = compute_files_hash(&m2, tmp.path()).unwrap();

    assert_eq!(
        h1, h2,
        "filesHash musi być taki sam niezależnie od kolejności deklaracji (sortowanie po path)"
    );
}

#[test]
fn files_hash_excludes_non_managed_and_delete() {
    let tmp = tempfile::tempdir().unwrap();
    let content = b"data";
    let hash = sha256_bytes(content);
    fs::write(tmp.path().join("managed.lua"), content).unwrap();
    fs::write(tmp.path().join("user_config.lua"), content).unwrap();

    // managed.lua jest w filesHash, user_config nie (managed=false), old.lua to delete
    let json = format!(
        r#"{{
        "schemaVersion": "2", "manifestId": "t:1", "version": "1.0.0",
        "releaseDate": "2026-03-03", "generatedAtUtc": "2026-03-03T00:00:00Z", "channel": "test",
        "filesHashExpected": "x",
        "files": [
            {{"path": "managed.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}},
            {{"path": "user_config.lua", "sha256": "{hash}", "size": {size}, "action": "file", "managed": false, "includeInFilesHash": false, "overwritePolicy": "never"}},
            {{"path": "old.lua", "action": "delete", "managed": true, "includeInFilesHash": false}}
        ]
    }}"#,
        hash = hash,
        size = content.len()
    );

    let manifest = parse_manifest_compat(&json).unwrap();
    let h = compute_files_hash(&manifest, tmp.path()).unwrap();
    assert_eq!(h.len(), 64);

    // Zmiana user_config NIE powinna wpłynąć na filesHash
    fs::write(tmp.path().join("user_config.lua"), b"changed!").unwrap();
    let h2 = compute_files_hash(&manifest, tmp.path()).unwrap();
    assert_eq!(
        h, h2,
        "Zmiana pliku nie-managed nie powinna wpłynąć na filesHash"
    );
}

#[test]
fn files_hash_missing_marker_is_predictable() {
    let tmp = tempfile::tempdir().unwrap();
    // NIE tworzymy żadnych plików — wszystkie powinny dać "MISSING"

    let json = r#"{
        "schemaVersion": "2", "manifestId": "t:1", "version": "1.0.0",
        "releaseDate": "2026-03-03", "generatedAtUtc": "2026-03-03T00:00:00Z", "channel": "test",
        "filesHashExpected": "x",
        "files": [
            {"path": "a.lua", "sha256": "aaaa", "size": 10, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"},
            {"path": "b.lua", "sha256": "bbbb", "size": 10, "action": "file", "managed": true, "includeInFilesHash": true, "overwritePolicy": "always"}
        ]
    }"#;

    let manifest = parse_manifest_compat(json).unwrap();
    let h1 = compute_files_hash(&manifest, tmp.path()).unwrap();
    let h2 = compute_files_hash(&manifest, tmp.path()).unwrap();

    assert_eq!(h1, h2, "MISSING daje przewidywalny, powtarzalny wynik");
    assert_eq!(h1.len(), 64);
}

// ═════════════════════════════════════════════
// Walidacja URL
// ═════════════════════════════════════════════

#[test]
fn url_validation_accepts_valid_https() {
    assert!(validate_url("https://cdn.example.com/files/", true).is_ok());
    assert!(validate_url(
        "https://api.example.com:8443/update.php?channel=stable",
        true
    )
    .is_ok());
}

#[test]
fn url_validation_rejects_http_when_https_required() {
    assert!(validate_url("http://api.example.com/", true).is_err());
}

#[test]
fn url_validation_accepts_http_when_not_required() {
    assert!(validate_url("http://localhost:8080/test", false).is_ok());
}

// ═════════════════════════════════════════════
// Walidacja semver
// ═════════════════════════════════════════════

#[test]
fn semver_validation_accepts_standard() {
    assert!(validate_semver("1.0.0").is_ok());
    assert!(validate_semver("0.2.0").is_ok());
    assert!(validate_semver("123.456.789").is_ok());
}

#[test]
fn semver_validation_rejects_garbage() {
    assert!(validate_semver("abc").is_err());
    assert!(validate_semver("1.x.0").is_err());
    assert!(validate_semver("").is_err());
}

// ═════════════════════════════════════════════
// Walidacja channel
// ═════════════════════════════════════════════

#[test]
fn channel_validation_accepts_known() {
    assert!(validate_channel("stable").is_ok());
    assert!(validate_channel("test").is_ok());
    assert!(validate_channel("dev").is_ok());
}

#[test]
fn channel_validation_rejects_unknown() {
    assert!(validate_channel("hacked_channel").is_err());
    assert!(validate_channel("production").is_err());
    assert!(validate_channel("").is_err());
}

// ═════════════════════════════════════════════
// Walidacja SHA-256
// ═════════════════════════════════════════════

#[test]
fn sha256_validation_accepts_valid() {
    let hash = "a".repeat(64);
    assert!(validate_sha256_hex(&hash).is_ok());
}

#[test]
fn sha256_validation_rejects_short() {
    assert!(validate_sha256_hex("abc").is_err());
}

#[test]
fn sha256_validation_rejects_non_hex() {
    let hash = "z".repeat(64);
    assert!(validate_sha256_hex(&hash).is_err());
}

// ═════════════════════════════════════════════
// Grace period
// ═════════════════════════════════════════════

#[test]
fn grace_period_current_hash_always_accepted() {
    assert!(is_files_hash_acceptable("abc123", None, "abc123", false));
    assert!(is_files_hash_acceptable("abc123", None, "abc123", true));
}

#[test]
fn grace_period_previous_hash_accepted_when_active() {
    assert!(is_files_hash_acceptable(
        "new_hash",
        Some("old_hash"),
        "old_hash",
        true
    ));
}

#[test]
fn grace_period_previous_hash_rejected_when_expired() {
    assert!(!is_files_hash_acceptable(
        "new_hash",
        Some("old_hash"),
        "old_hash",
        false
    ));
}

#[test]
fn grace_period_active_check_by_date() {
    // Grace do 10 marca, teraz 3 marca → aktywny
    assert!(is_grace_period_active(
        Some("2026-03-10T00:00:00Z"),
        "2026-03-03T12:00:00Z"
    ));

    // Grace do 1 marca, teraz 3 marca → wygasły
    assert!(!is_grace_period_active(
        Some("2026-03-01T00:00:00Z"),
        "2026-03-03T12:00:00Z"
    ));

    // Brak grace → nie aktywny
    assert!(!is_grace_period_active(None, "2026-03-03T12:00:00Z"));
}
