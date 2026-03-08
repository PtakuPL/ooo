mod downloader;
mod i18n;
mod installer;
mod platform;
mod ui;

use serde::Deserialize;
use std::path::PathBuf;
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

    // Check for --uninstall flag before anything else
    let args: Vec<String> = std::env::args().collect();
    if args.iter().any(|a| a == "--uninstall") {
        let lang = i18n::resolve_language();
        i18n::init(lang);

        if let Err(msg) = run_uninstall() {
            ui::show_error(&msg);
            process::exit(1);
        }
        return;
    }

    let lang = i18n::resolve_language();
    i18n::init(lang);

    if let Err(msg) = run() {
        ui::show_error(&msg);
        process::exit(1);
    }
}

/// Uninstall mode — invoked via `--uninstall` flag (or from Windows Add/Remove Programs).
fn run_uninstall() -> Result<(), String> {
    let s = i18n::t();

    // Determine install directory
    let install_dir = determine_install_dir_for_uninstall();

    if !install_dir.exists() {
        return Err(format!("Install directory not found: {}", install_dir.display()));
    }

    // Confirm with user
    if !ui::confirm_yes_no(s.bootstrap_title, s.uninstall_confirm) {
        return Ok(());
    }

    installer::uninstall(&install_dir)?;

    // Show completion message
    let final_msg = format!("{}\n\n{}", s.uninstall_complete, s.uninstall_bootstrap_hint);
    ui::show_info(&final_msg);

    Ok(())
}

/// Determine the install directory for uninstall.
/// Priority: 1) exe parent (if it has launcher_config.json), 2) registry, 3) default.
fn determine_install_dir_for_uninstall() -> PathBuf {
    // 1. If running from inside the install directory
    if let Ok(exe) = std::env::current_exe() {
        if let Some(parent) = exe.parent() {
            if parent.join("launcher_config.json").exists() {
                return parent.to_path_buf();
            }
        }
    }

    // 2. Try registry (Windows)
    if let Some(dir) = installer::read_install_location() {
        return dir;
    }

    // 3. Fall back to default
    platform::default_install_dir()
}

fn run() -> Result<(), String> {
    let s = i18n::t();

    ui::set_status(&format!(
        "RedDaxe.pl Installer v{BOOTSTRAP_VERSION} \u{2014} {}", s.installing_launcher
    ));

    // Pre-install: check registry/default location BEFORE showing folder picker
    let existing_dir = installer::read_install_location()
        .or_else(|| {
            let default = platform::default_install_dir();
            if installer::launcher_already_installed(&default) {
                Some(default)
            } else {
                None
            }
        });

    let install_dir = if let Some(ref existing) = existing_dir {
        // Found existing installation — ask user what to do BEFORE folder picker
        let prompt_msg = format!(
            "{}\n{}\n\n{}",
            s.existing_installation,
            existing.display(),
            s.existing_install_uninstall_prompt
        );
        match ui::confirm_yes_no_cancel(s.bootstrap_title, &prompt_msg) {
            Some(true) => {
                // YES = uninstall everything and exit
                installer::uninstall(existing)?;
                let final_msg = format!(
                    "{}\n\n{}", s.uninstall_complete, s.uninstall_bootstrap_hint
                );
                ui::show_info(&final_msg);
                return Ok(());
            }
            Some(false) => {
                // NO = update in-place (reuse existing dir, skip folder picker)
                ui::set_status(s.updating);
                existing.clone()
            }
            None => {
                // CANCEL = abort
                return Ok(());
            }
        }
    } else {
        // No existing installation — show folder picker
        platform::ask_install_dir(s.bootstrap_title, s.choose_install_dir)
    };

    let client = reqwest::blocking::Client::builder()
        .user_agent(format!("RedDaxe-Installer/{BOOTSTRAP_VERSION}"))
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
    let tmp_dir = std::env::temp_dir().join("reddaxe_installer");
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

    // 5a. Copy bootstrap to install_dir as uninstaller
    installer::copy_self_to_install_dir(&install_dir)
        .map_err(|e| format!("{e}"))?;

    // 5b. Register in Windows Add/Remove Programs
    #[cfg(target_os = "windows")]
    {
        installer::register_uninstaller(&install_dir)
            .map_err(|e| format!("{e}"))?;
    }

    // 5c. Create shortcuts
    ui::set_status(s.creating_shortcuts);
    let want_desktop = ui::confirm_yes_no(s.bootstrap_title, s.desktop_shortcut_prompt);
    platform::create_shortcuts(&install_dir, want_desktop);

    // 6. Cleanup temp
    let _ = std::fs::remove_dir_all(&tmp_dir);

    // 7. Show install path + launch
    ui::set_status(&format!("{} {}", s.installed_at, install_dir.display()));
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
