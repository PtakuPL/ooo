//! Modele manifestu klienta (v1, v2, znormalizowany).
//!
//! Launcher pobiera manifest z `update.php`, parsuje go jako v1 lub v2,
//! i normalizuje do jednego modelu wewnętrznego `NormalizedManifest`.

use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;

// ─────────────────────────────────────────────
// Raw V2 (docelowy manifest z API)
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestV2Raw {
    pub schema_version: String,
    pub manifest_id: String,
    pub version: String,
    pub release_date: String,
    pub generated_at_utc: String,
    pub channel: String,

    #[serde(default)]
    pub min_launcher_version: Option<String>,

    #[serde(default)]
    pub base_url: Option<String>,

    #[serde(default)]
    pub files_hash_expected: Option<String>,

    #[serde(default)]
    pub files: Vec<ManifestFileEntryV2Raw>,

    #[serde(default)]
    pub servers: Vec<ServerEntryRaw>,

    #[serde(default)]
    pub changelog: Vec<ChangelogEntryRaw>,

    #[serde(default)]
    pub grace_previous_version_accepted_until_utc: Option<String>,

    #[serde(default)]
    pub signature: Option<String>,

    #[serde(default)]
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntryV2Raw {
    pub path: String,

    #[serde(default)]
    pub sha256: Option<String>,

    #[serde(default)]
    pub size: Option<u64>,

    #[serde(default)]
    pub url: Option<String>,

    #[serde(default = "default_true")]
    pub managed: bool,

    #[serde(default)]
    pub action: ManifestFileAction,

    #[serde(default)]
    pub required: bool,

    #[serde(default = "default_true")]
    pub include_in_files_hash: bool,

    #[serde(default)]
    pub overwrite_policy: OverwritePolicy,

    #[serde(default)]
    pub delete_policy: DeletePolicy,

    #[serde(default)]
    pub executable: bool,

    #[serde(default)]
    pub tags: Vec<String>,

    #[serde(default)]
    pub mode: Option<String>,

    #[serde(default)]
    pub compressed_size: Option<u64>,

    #[serde(default)]
    pub etag: Option<String>,

    #[serde(default)]
    pub last_modified_utc: Option<String>,
}

// ─────────────────────────────────────────────
// Raw V1 (legacy manifest z obecnego API / Python MVP)
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestV1Raw {
    pub version: String,
    pub release_date: String,
    pub channel: String,

    #[serde(default)]
    pub files: Vec<ManifestFileEntryV1Raw>,

    #[serde(default)]
    pub changelog: Vec<ChangelogEntryRaw>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntryV1Raw {
    pub path: String,
    pub sha256: String,
    pub size: u64,
    pub url: String,
}

// ─────────────────────────────────────────────
// Enumy wspólne
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum ManifestFileAction {
    #[default]
    File,
    Delete,
    Mkdir,
    Noop,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum OverwritePolicy {
    Always,
    #[default]
    IfHashDiffers,
    Never,
    PreserveUser,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default, PartialEq, Eq)]
#[serde(rename_all = "snake_case")]
pub enum DeletePolicy {
    Allow,
    #[default]
    Protect,
    OrphanCleanup,
}

// ─────────────────────────────────────────────
// Modele pomocnicze
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ServerEntryRaw {
    pub id: String,
    pub name: String,
    pub host: String,
    pub port: u16,

    #[serde(default)]
    pub game_mode: Option<String>,

    #[serde(default = "default_true")]
    pub visible: bool,

    #[serde(default = "default_true")]
    pub enabled: bool,

    #[serde(default)]
    pub priority: i32,

    #[serde(default)]
    pub channel: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub struct ChangelogEntryRaw {
    pub date: String,
    pub text: String,
}

// ─────────────────────────────────────────────
// Model znormalizowany (wewnętrzny dla launchera)
// ─────────────────────────────────────────────

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct NormalizedManifest {
    pub schema_version: String,
    pub manifest_id: String,
    pub version: String,
    pub release_date: String,
    pub generated_at_utc: Option<String>,
    pub channel: String,

    pub min_launcher_version: Option<String>,
    pub base_url: Option<String>,
    pub files_hash_expected: Option<String>,

    pub files: Vec<ManifestFileEntry>,
    pub servers: Vec<ServerEntryRaw>,
    pub changelog: Vec<ChangelogEntryRaw>,

    pub grace_previous_version_accepted_until_utc: Option<String>,
    pub signature: Option<String>,
    pub notes: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ManifestFileEntry {
    pub path: String,
    pub sha256: Option<String>,
    pub size: Option<u64>,
    pub url: Option<String>,

    pub managed: bool,
    pub action: ManifestFileAction,
    pub required: bool,
    pub include_in_files_hash: bool,
    pub overwrite_policy: OverwritePolicy,
    pub delete_policy: DeletePolicy,
    pub executable: bool,
    pub tags: Vec<String>,
    pub mode: Option<String>,
}

// ─────────────────────────────────────────────
// Walidacja manifestu
// ─────────────────────────────────────────────

#[derive(Debug, thiserror::Error)]
pub enum ManifestValidationError {
    #[error("Invalid field: {0}")]
    InvalidField(&'static str),

    #[error("Duplicate path in manifest: {0}")]
    DuplicatePath(String),

    #[error("Missing field '{field}' for managed file '{path}'")]
    MissingRequiredForFile { path: String, field: &'static str },

    #[error("Path traversal detected: {0}")]
    PathTraversal(String),

    #[error("filesHashExpected required for v2 manifest")]
    FilesHashExpectedRequired,
}

impl NormalizedManifest {
    /// Podstawowa walidacja manifestu po normalizacji.
    pub fn validate_basic(&self) -> Result<(), ManifestValidationError> {
        if self.version.trim().is_empty() {
            return Err(ManifestValidationError::InvalidField("version"));
        }
        if self.channel.trim().is_empty() {
            return Err(ManifestValidationError::InvalidField("channel"));
        }
        if self.files.is_empty() {
            return Err(ManifestValidationError::InvalidField("files"));
        }

        // filesHashExpected wymagane dla v2, opcjonalne dla v1-compat
        if self.schema_version.starts_with('2') {
            if self.files_hash_expected.as_deref().unwrap_or("").is_empty() {
                return Err(ManifestValidationError::FilesHashExpectedRequired);
            }
        }

        let mut seen = BTreeSet::new();
        for f in &self.files {
            // Walidacja ścieżek
            validate_safe_rel_path(&f.path)?;

            // Duplikaty path
            if !seen.insert(f.path.clone()) {
                return Err(ManifestValidationError::DuplicatePath(f.path.clone()));
            }

            // Walidacja pól zależnych od action
            validate_file_entry_fields(f)?;
        }

        Ok(())
    }

    /// Zwraca pliki uczestniczące w filesHash (managed + action=file + includeInFilesHash).
    pub fn files_hash_entries(&self) -> Vec<&ManifestFileEntry> {
        self.files
            .iter()
            .filter(|f| {
                f.managed && f.action == ManifestFileAction::File && f.include_in_files_hash
            })
            .collect()
    }
}

// ─────────────────────────────────────────────
// Walidacja ścieżek (path traversal protection)
// ─────────────────────────────────────────────

/// LR-074: Bezpieczna walidacja ścieżek w manifeście.
/// Odrzuca `..`, ścieżki absolutne, dwukropek i inne niebezpieczne segmenty.
pub fn validate_safe_rel_path(path: &str) -> Result<(), ManifestValidationError> {
    let p = path.replace('\\', "/");

    if p.trim().is_empty() {
        return Err(ManifestValidationError::PathTraversal(
            "empty path".to_string(),
        ));
    }
    if p.starts_with('/') {
        return Err(ManifestValidationError::PathTraversal(format!(
            "absolute path not allowed: {path}"
        )));
    }
    if p.contains("../") || p.ends_with("/..") || p == ".." {
        return Err(ManifestValidationError::PathTraversal(format!(
            "path traversal not allowed: {path}"
        )));
    }
    if p.contains(':') {
        return Err(ManifestValidationError::PathTraversal(format!(
            "colon not allowed in relative manifest path: {path}"
        )));
    }
    // Zabezpieczenie przed NULL byte
    if p.contains('\0') {
        return Err(ManifestValidationError::PathTraversal(format!(
            "null byte in path: {path}"
        )));
    }

    Ok(())
}

/// LR-075: Walidacja pól zależnych od action.
fn validate_file_entry_fields(f: &ManifestFileEntry) -> Result<(), ManifestValidationError> {
    match f.action {
        ManifestFileAction::File => {
            if f.managed {
                if f.sha256.as_deref().unwrap_or("").is_empty() {
                    return Err(ManifestValidationError::MissingRequiredForFile {
                        path: f.path.clone(),
                        field: "sha256",
                    });
                }
                if f.size.is_none() {
                    return Err(ManifestValidationError::MissingRequiredForFile {
                        path: f.path.clone(),
                        field: "size",
                    });
                }
            }
        }
        ManifestFileAction::Delete => {
            // Dla delete nie wymagamy sha256/size/url — to poprawne.
        }
        ManifestFileAction::Mkdir | ManifestFileAction::Noop => {
            // MVP: dozwolone, patcher obsługuje je warunkowo.
        }
    }

    Ok(())
}

// ─────────────────────────────────────────────
// Parser kompatybilny v1 -> v2 (normalizacja)
// ─────────────────────────────────────────────

#[derive(Debug, thiserror::Error)]
pub enum ManifestParseError {
    #[error("JSON parse error: {0}")]
    Json(#[from] serde_json::Error),

    #[error("Validation error: {0}")]
    Validation(#[from] ManifestValidationError),

    #[error("Unsupported schema version: {0}")]
    UnsupportedSchema(String),
}

/// LR-072: Parser kompatybilny z v1 i v2.
/// Dla braku `schemaVersion` → fallback do v1.
/// Po normalizacji uruchamia `validate_basic()`.
pub fn parse_manifest_compat(json_text: &str) -> Result<NormalizedManifest, ManifestParseError> {
    let value: serde_json::Value = serde_json::from_str(json_text)?;

    let normalized = match value.get("schemaVersion").and_then(|v| v.as_str()) {
        Some(schema) if schema.starts_with('2') => {
            let raw: ManifestV2Raw = serde_json::from_value(value)?;
            normalize_v2(raw)?
        }
        Some(other) => {
            return Err(ManifestParseError::UnsupportedSchema(other.to_string()));
        }
        None => {
            // Legacy v1 fallback
            let raw: ManifestV1Raw = serde_json::from_value(value)?;
            normalize_v1(raw)?
        }
    };

    normalized.validate_basic()?;
    Ok(normalized)
}

fn normalize_v2(raw: ManifestV2Raw) -> Result<NormalizedManifest, ManifestParseError> {
    let files = raw
        .files
        .into_iter()
        .map(|f| ManifestFileEntry {
            path: normalize_rel_path(&f.path),
            sha256: normalize_opt_string(f.sha256),
            size: f.size,
            url: normalize_opt_string(f.url),
            managed: f.managed,
            action: f.action,
            required: f.required,
            include_in_files_hash: f.include_in_files_hash,
            overwrite_policy: f.overwrite_policy,
            delete_policy: f.delete_policy,
            executable: f.executable,
            tags: normalize_tags(f.tags),
            mode: f.mode,
        })
        .collect();

    Ok(NormalizedManifest {
        schema_version: raw.schema_version,
        manifest_id: if raw.manifest_id.trim().is_empty() {
            format!("{}:{}", raw.channel, raw.version)
        } else {
            raw.manifest_id
        },
        version: raw.version,
        release_date: raw.release_date,
        generated_at_utc: Some(raw.generated_at_utc),
        channel: raw.channel,
        min_launcher_version: raw.min_launcher_version,
        base_url: raw.base_url,
        files_hash_expected: raw.files_hash_expected,
        files,
        servers: raw.servers,
        changelog: raw.changelog,
        grace_previous_version_accepted_until_utc: raw.grace_previous_version_accepted_until_utc,
        signature: raw.signature,
        notes: raw.notes,
    })
}

fn normalize_v1(raw: ManifestV1Raw) -> Result<NormalizedManifest, ManifestParseError> {
    let files = raw
        .files
        .into_iter()
        .map(|f| ManifestFileEntry {
            path: normalize_rel_path(&f.path),
            sha256: Some(f.sha256),
            size: Some(f.size),
            url: Some(f.url),
            managed: true,
            action: ManifestFileAction::File,
            required: true,
            include_in_files_hash: true,
            overwrite_policy: OverwritePolicy::IfHashDiffers,
            delete_policy: DeletePolicy::Protect,
            executable: is_probably_executable(&f.path),
            tags: infer_tags_from_path(&f.path),
            mode: None,
        })
        .collect();

    Ok(NormalizedManifest {
        schema_version: "1-compat".to_string(),
        manifest_id: format!("{}:{}", raw.channel, raw.version),
        version: raw.version,
        release_date: raw.release_date,
        generated_at_utc: None,
        channel: raw.channel,
        min_launcher_version: None,
        base_url: None,
        files_hash_expected: None,
        files,
        servers: Vec::new(),
        changelog: raw.changelog,
        grace_previous_version_accepted_until_utc: None,
        signature: None,
        notes: None,
    })
}

// ─────────────────────────────────────────────
// Helpery normalizacji
// ─────────────────────────────────────────────

fn normalize_rel_path(input: &str) -> String {
    let p = input.trim().replace('\\', "/");
    p.trim_start_matches("./").to_string()
}

fn normalize_opt_string(v: Option<String>) -> Option<String> {
    v.and_then(|s| {
        let t = s.trim().to_string();
        if t.is_empty() {
            None
        } else {
            Some(t)
        }
    })
}

fn normalize_tags(tags: Vec<String>) -> Vec<String> {
    tags.into_iter()
        .map(|t| t.trim().to_lowercase())
        .filter(|t| !t.is_empty())
        .collect()
}

fn is_probably_executable(path: &str) -> bool {
    let p = path.to_ascii_lowercase();
    p.ends_with(".exe") || p.ends_with(".bat") || p.ends_with(".cmd")
}

fn infer_tags_from_path(path: &str) -> Vec<String> {
    let p = path.to_ascii_lowercase();
    let mut tags = Vec::new();

    if p.ends_with(".exe") || p.ends_with(".dll") {
        tags.push("client-bin".to_string());
    }
    if p.ends_with(".lua") {
        tags.push("lua".to_string());
    }
    if p.ends_with(".otui") {
        tags.push("otui".to_string());
    }
    if p.contains("/modules/") {
        tags.push("ui".to_string());
    }
    if p.contains("/data/") || p.contains("/assets/") {
        tags.push("asset".to_string());
    }

    tags
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
    fn test_parse_v1_manifest() {
        let json = include_str!("../tests/fixtures/manifest_v1.json");
        let manifest = parse_manifest_compat(json).expect("v1 parse failed");
        assert_eq!(manifest.schema_version, "1-compat");
        assert_eq!(manifest.version, "1.0.2");
        assert_eq!(manifest.channel, "stable");
        assert_eq!(manifest.manifest_id, "stable:1.0.2");
        assert!(manifest.files_hash_expected.is_none());
        assert!(!manifest.files.is_empty());

        // Sprawdź domyślne flagi v1 → normalized
        for f in &manifest.files {
            assert!(f.managed);
            assert_eq!(f.action, ManifestFileAction::File);
            assert!(f.include_in_files_hash);
            assert_eq!(f.overwrite_policy, OverwritePolicy::IfHashDiffers);
            assert_eq!(f.delete_policy, DeletePolicy::Protect);
        }
    }

    #[test]
    fn test_parse_v2_manifest() {
        let json = include_str!("../tests/fixtures/manifest_v2.json");
        let manifest = parse_manifest_compat(json).expect("v2 parse failed");
        assert_eq!(manifest.schema_version, "2.0");
        assert_eq!(manifest.version, "1.0.3");
        assert_eq!(manifest.channel, "stable");
        assert_eq!(manifest.manifest_id, "stable:1.0.3");
        assert!(manifest.files_hash_expected.is_some());
        assert!(!manifest.files.is_empty());
    }

    #[test]
    fn test_reject_unsupported_schema() {
        let json = r#"{"schemaVersion":"3.0","version":"1","channel":"stable","files":[]}"#;
        let result = parse_manifest_compat(json);
        assert!(matches!(
            result,
            Err(ManifestParseError::UnsupportedSchema(_))
        ));
    }

    #[test]
    fn test_reject_empty_version() {
        let json = r#"{"version":"","releaseDate":"2026-01-01","channel":"stable","files":[{"path":"a.txt","sha256":"abc","size":10,"url":"http://x"}]}"#;
        let result = parse_manifest_compat(json);
        assert!(result.is_err());
    }

    #[test]
    fn test_reject_duplicate_path() {
        let json = r#"{
            "version": "1.0.0",
            "releaseDate": "2026-01-01",
            "channel": "stable",
            "files": [
                {"path": "a.txt", "sha256": "aaaa", "size": 10, "url": "http://x/a"},
                {"path": "a.txt", "sha256": "bbbb", "size": 20, "url": "http://x/b"}
            ]
        }"#;
        let result = parse_manifest_compat(json);
        assert!(matches!(
            result,
            Err(ManifestParseError::Validation(
                ManifestValidationError::DuplicatePath(_)
            ))
        ));
    }

    #[test]
    fn test_reject_path_traversal() {
        let cases = vec![
            r#"{"version":"1","releaseDate":"2026-01-01","channel":"stable","files":[{"path":"../etc/passwd","sha256":"aa","size":1,"url":"x"}]}"#,
            r#"{"version":"1","releaseDate":"2026-01-01","channel":"stable","files":[{"path":"/etc/passwd","sha256":"aa","size":1,"url":"x"}]}"#,
            r#"{"version":"1","releaseDate":"2026-01-01","channel":"stable","files":[{"path":"C:\\Windows\\system32","sha256":"aa","size":1,"url":"x"}]}"#,
        ];
        for json in cases {
            let result = parse_manifest_compat(json);
            assert!(
                matches!(
                    result,
                    Err(ManifestParseError::Validation(
                        ManifestValidationError::PathTraversal(_)
                    ))
                ),
                "Should reject: {json}"
            );
        }
    }

    #[test]
    fn test_accept_delete_without_hash() {
        let json = r#"{
            "schemaVersion": "2.0",
            "manifestId": "stable:1.0.3",
            "version": "1.0.3",
            "releaseDate": "2026-03-02",
            "generatedAtUtc": "2026-03-02T18:00:00Z",
            "channel": "stable",
            "filesHashExpected": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "files": [
                {"path": "keep.exe", "sha256": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890", "size": 100, "url": "http://x/keep", "managed": true, "action": "file"},
                {"path": "old_file.dll", "managed": true, "action": "delete"}
            ]
        }"#;
        let manifest = parse_manifest_compat(json).expect("delete entry should be accepted");
        assert_eq!(manifest.files.len(), 2);
        assert_eq!(manifest.files[1].action, ManifestFileAction::Delete);
    }

    #[test]
    fn test_reject_managed_file_without_hash() {
        let json = r#"{
            "schemaVersion": "2.0",
            "manifestId": "stable:1.0.0",
            "version": "1.0.0",
            "releaseDate": "2026-01-01",
            "generatedAtUtc": "2026-01-01T00:00:00Z",
            "channel": "stable",
            "filesHashExpected": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "files": [
                {"path": "no_hash.exe", "managed": true, "action": "file", "size": 100}
            ]
        }"#;
        let result = parse_manifest_compat(json);
        assert!(matches!(
            result,
            Err(ManifestParseError::Validation(
                ManifestValidationError::MissingRequiredForFile { .. }
            ))
        ));
    }

    #[test]
    fn test_path_normalization() {
        assert_eq!(normalize_rel_path("./modules/test.lua"), "modules/test.lua");
        assert_eq!(normalize_rel_path("modules\\test.lua"), "modules/test.lua");
        assert_eq!(normalize_rel_path("  data/file.spr  "), "data/file.spr");
    }

    #[test]
    fn test_safe_path_validation() {
        assert!(validate_safe_rel_path("modules/test.lua").is_ok());
        assert!(validate_safe_rel_path("data/sprites/outfit.spr").is_ok());
        assert!(validate_safe_rel_path("otclient.exe").is_ok());

        assert!(validate_safe_rel_path("../etc/passwd").is_err());
        assert!(validate_safe_rel_path("/absolute/path").is_err());
        assert!(validate_safe_rel_path("C:\\Windows").is_err());
        assert!(validate_safe_rel_path("").is_err());
        assert!(validate_safe_rel_path("   ").is_err());
    }

    #[test]
    fn test_files_hash_entries_filter() {
        let json = include_str!("../tests/fixtures/manifest_v2.json");
        let manifest = parse_manifest_compat(json).expect("v2 parse failed");
        let hash_entries = manifest.files_hash_entries();
        // Tylko managed + action=file + includeInFilesHash
        for entry in &hash_entries {
            assert!(entry.managed);
            assert_eq!(entry.action, ManifestFileAction::File);
            assert!(entry.include_in_files_hash);
        }
    }

    #[test]
    fn test_infer_tags() {
        assert!(infer_tags_from_path("otclient.exe").contains(&"client-bin".to_string()));
        assert!(infer_tags_from_path("modules/ui/test.lua").contains(&"lua".to_string()));
        assert!(infer_tags_from_path("modules/ui/test.lua").contains(&"ui".to_string()));
        assert!(infer_tags_from_path("data/sprites.spr").contains(&"asset".to_string()));
    }
}
