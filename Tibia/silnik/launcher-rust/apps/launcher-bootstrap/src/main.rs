mod downloader;
mod installer;
mod platform;
mod ui;

use serde::Deserialize;
use std::process;

/// API base URL baked into the binary.  
/// The bootstrap launcher talks only to this endpoint.
const API_BASE: &str = "https://twojserwer.pl/apik/v1";
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
    if let Err(msg) = run() {
        ui::show_error(&msg);
        process::exit(1);
    }
}

fn run() -> Result<(), String> {
    ui::set_status(&format!(
        "SerwerCanary Bootstrap v{BOOTSTRAP_VERSION} — instalacja launchera"
    ));

    let install_dir = platform::default_install_dir();

    // Check for existing installation
    if installer::launcher_already_installed(&install_dir) {
        ui::set_status("Wykryto istniejącą instalację launchera.");
        ui::set_status("Aktualizuję do najnowszej wersji…");
    }

    // Build HTTP client (no extra runtime — blocking reqwest)
    let client = reqwest::blocking::Client::builder()
        .user_agent(format!("SerwerCanary-Bootstrap/{BOOTSTRAP_VERSION}"))
        .timeout(std::time::Duration::from_secs(120))
        .build()
        .map_err(|e| format!("Nie można utworzyć klienta HTTP: {e}"))?;

    // 1. Fetch installer catalog
    ui::set_status("Pobieranie katalogu artefaktów…");
    let catalog_url = format!(
        "{API_BASE}{CATALOG_ENDPOINT}?channel=stable&type=launcher"
    );
    let json_body = downloader::fetch_json(&client, &catalog_url)
        .map_err(|e| format!("{e}"))?;

    let catalog: CatalogResponse = serde_json::from_str(&json_body)
        .map_err(|e| format!("Nieprawidłowa odpowiedź API: {e}"))?;

    // 2. Find the right artifact for this platform
    let artifact = find_artifact(&catalog)
        .ok_or_else(|| {
            format!(
                "Brak artefaktu dla platformy {} / {}",
                platform::platform_name(),
                platform::arch_name()
            )
        })?;

    ui::set_status(&format!(
        "Pobieranie pełnego launchera: {} …",
        artifact.filename
    ));

    // 3. Download to a temporary file
    let tmp_dir = std::env::temp_dir().join("serwercanary_bootstrap");
    std::fs::create_dir_all(&tmp_dir)
        .map_err(|e| format!("Nie można utworzyć katalogu tymczasowego: {e}"))?;

    let download_path = tmp_dir.join(&artifact.filename);

    downloader::download_and_verify(&client, &artifact.url, &artifact.sha256, &download_path)
        .map_err(|e| format!("{e}"))?;

    ui::set_status("Pobieranie zakończone. Weryfikacja SHA-256 OK.");

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
    ui::set_status("Instalacja zakończona! Uruchamiam launcher…");
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
