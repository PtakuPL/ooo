mod downloader;
mod i18n;
mod installer;
mod platform;
mod ui;

use serde::Deserialize;
use std::process;

/// API base URL baked into the binary.  
/// The bootstrap launcher talks only to this endpoint.
const API_BASE: &str = "https://127.0.0.1/apik/v1";
const CATALOG_ENDPOINT: &str = "/installer-catalog.php";
const BOOTSTRAP_VERSION: &str = env!("CARGO_PKG_VERSION");

// ── API response structs ──

#[derive(Debug, Deserialize)]
struct CatalogResponse {
    artifacts: Vec<CatalogArtifact>,
}

#[derive(Debug, Deserialize)]
#[allow(dead_code)]
struct CatalogArtifact {
    #[serde(default)]
    id: String,
    #[serde(default)]
    platform: String,
    #[serde(default)]
    arch: String,
    url: String,
    #[serde(default)]
    sha256: String,
    #[serde(default)]
    filename: String,
    #[serde(default, rename = "type")]
    artifact_type: String,
}

fn main() {
    // 0. Console UTF-8 + language resolution (before any output)
    ui::init_console_utf8();
    let lang = i18n::resolve_language();
    i18n::init(lang);

    if let Err(msg) = run() {
        ui::show_error(&msg);
        process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let s = i18n::t();

    ui::set_status(&format!(
        "SerwerCanary Bootstrap v{BOOTSTRAP_VERSION} \u{2014} {}", s.installing_launcher
    ));

    let install_dir = platform::default_install_dir();

    if installer::launcher_already_installed(&install_dir) {
        ui::set_status(s.existing_installation);
        ui::set_status(s.updating);
    }

    let client = reqwest::blocking::Client::builder()
        .user_agent(format!("SerwerCanary-Bootstrap/{BOOTSTRAP_VERSION}"))
        .timeout(std::time::Duration::from_secs(120))
        .danger_accept_invalid_certs(true)
        .build()
        .map_err(|e| format!("{}: {e}", s.error_http_client))?;

    // 1. Fetch installer catalog
    ui::set_status(s.fetching_catalog);
    let catalog_url = format!(
        "{API_BASE}{CATALOG_ENDPOINT}?channel=stable&type=launcher"
    );
    let json_body = downloader::fetch_json(&client, &catalog_url)
        .map_err(|e| format!("{e}"))?;

    let catalog: CatalogResponse = serde_json::from_str(&json_body)
        .map_err(|e| format!("{}: {e}", s.invalid_api_response))?;

    // 2. Find the right artifact for this platform
    let artifact = find_artifact(&catalog)
        .ok_or_else(|| {
            format!(
                "{}: {} / {}",
                s.no_artifact,
                platform::platform_name(),
                platform::arch_name()
            )
        })?;

    ui::set_status(&format!(
        "{}: {} \u{2026}",
        s.downloading_launcher, artifact.filename
    ));

    // 3. Download to a temporary file
    let tmp_dir = std::env::temp_dir().join("serwercanary_bootstrap");
    std::fs::create_dir_all(&tmp_dir)
        .map_err(|e| format!("{}: {e}", s.error_temp_dir))?;

    let download_path = tmp_dir.join(&artifact.filename);

    downloader::download_and_verify(&client, &artifact.url, &artifact.sha256, &download_path)
        .map_err(|e| format!("{e}"))?;

    ui::set_status(s.download_complete);

    // 4. Extract
    ui::reset_progress();
    let launcher_exe =
        installer::extract_launcher(&download_path, &install_dir)
            .map_err(|e| format!("{e}"))?;

    // 5. Write config
    installer::write_config(&install_dir, BOOTSTRAP_VERSION)
        .map_err(|e| format!("{e}"))?;

    // 6. Cleanup temp
    let _ = std::fs::remove_dir_all(&tmp_dir);

    // 7. Launch the full launcher
    ui::set_status(s.install_complete);
    installer::launch_full_launcher(&launcher_exe)
        .map_err(|e| format!("{e}"))?;

    Ok(())
}

/// Pick the artifact matching the current OS + arch.
fn find_artifact(catalog: &CatalogResponse) -> Option<&CatalogArtifact> {
    let os = platform::platform_name();
    let arch = platform::arch_name();

    // Try exact platform+arch match first
    catalog.artifacts.iter().find(|a| {
        a.platform.eq_ignore_ascii_case(os) && a.arch.eq_ignore_ascii_case(arch)
    }).or_else(|| {
        // Fallback: match on platform only (for legacy catalog without platform/arch fields)
        catalog.artifacts.iter().find(|a| {
            a.platform.eq_ignore_ascii_case(os)
        })
    }).or_else(|| {
        // Last resort: take the first artifact with a non-empty URL
        // (for the current simple catalog that has only one entry)
        catalog.artifacts.iter().find(|a| !a.url.is_empty())
    })
}
