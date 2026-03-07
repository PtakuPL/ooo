use std::fs;
use std::io::{self, Read};
use std::path::{Path, PathBuf};

use crate::platform;
use crate::ui;

/// Error type for installation operations.
#[derive(Debug)]
pub enum InstallError {
    Io(io::Error),
    Zip(String),
    LauncherNotFound,
}

impl std::fmt::Display for InstallError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Io(e) => write!(f, "Błąd I/O: {e}"),
            Self::Zip(msg) => write!(f, "Błąd rozpakowania: {msg}"),
            Self::LauncherNotFound => write!(
                f,
                "Nie znaleziono pliku launchera w pobranym archiwum"
            ),
        }
    }
}

impl From<io::Error> for InstallError {
    fn from(e: io::Error) -> Self {
        Self::Io(e)
    }
}

/// Extract a ZIP archive at `zip_path` into `install_dir`.
/// Returns the path to the launcher executable inside the extracted tree.
pub fn extract_launcher(zip_path: &Path, install_dir: &Path) -> Result<PathBuf, InstallError> {
    ui::set_status("Rozpakowywanie launchera…");

    fs::create_dir_all(install_dir)?;

    let file = fs::File::open(zip_path)?;
    let mut archive =
        zip::ZipArchive::new(file).map_err(|e| InstallError::Zip(e.to_string()))?;

    let total = archive.len();
    for i in 0..total {
        let mut entry = archive
            .by_index(i)
            .map_err(|e| InstallError::Zip(e.to_string()))?;

        let raw_name = entry.name().to_owned();

        // Security: reject paths that try to escape install_dir
        if raw_name.contains("..") {
            continue;
        }

        let out_path = install_dir.join(&raw_name);

        if entry.is_dir() {
            fs::create_dir_all(&out_path)?;
        } else {
            if let Some(parent) = out_path.parent() {
                fs::create_dir_all(parent)?;
            }
            let mut out_file = fs::File::create(&out_path)?;
            let mut buf = Vec::new();
            entry
                .read_to_end(&mut buf)
                .map_err(|e| InstallError::Zip(e.to_string()))?;
            io::Write::write_all(&mut out_file, &buf)?;
        }

        // Set executable permission on Linux
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            if let Some(mode) = entry.unix_mode() {
                let _ = fs::set_permissions(&out_path, fs::Permissions::from_mode(mode));
            }
        }

        let pct = ((i as f64 / total as f64) * 100.0) as u8;
        ui::set_progress(pct);
    }

    ui::set_progress(100);

    // Locate the launcher executable
    let launcher_path = find_launcher_exe(install_dir)?;
    Ok(launcher_path)
}

/// Write the default `launcher_config.json` next to the launcher exe.
pub fn write_config(install_dir: &Path, bootstrap_version: &str) -> Result<(), InstallError> {
    ui::set_status("Zapisywanie konfiguracji…");

    let config = serde_json::json!({
        "apiBaseUrl": "https://twojserwer.pl/apik/v1",
        "channel": "stable",
        "launcher_version_check": true,
        "client_dir": "client",
        "launcher_data_dir": "launcher_data",
        "installed_by_bootstrap": true,
        "bootstrap_version": bootstrap_version
    });

    let config_path = install_dir.join("launcher_config.json");

    // Do not overwrite existing config
    if !config_path.exists() {
        let json = serde_json::to_string_pretty(&config)
            .map_err(|e| InstallError::Io(io::Error::new(io::ErrorKind::Other, e.to_string())))?;
        fs::write(&config_path, json)?;
    }

    Ok(())
}

/// Check whether a full launcher is already installed in `install_dir`.
pub fn launcher_already_installed(install_dir: &Path) -> bool {
    install_dir.join(platform::launcher_exe_name()).exists()
}

/// Launch the full launcher executable.
pub fn launch_full_launcher(launcher_exe: &Path) -> Result<(), InstallError> {
    ui::set_status("Uruchamianie launchera…");

    let working_dir = launcher_exe
        .parent()
        .unwrap_or_else(|| Path::new("."));

    std::process::Command::new(launcher_exe)
        .current_dir(working_dir)
        .spawn()
        .map_err(InstallError::Io)?;

    Ok(())
}

// ── helpers ──

fn find_launcher_exe(install_dir: &Path) -> Result<PathBuf, InstallError> {
    let exe_name = platform::launcher_exe_name();

    // Check root
    let root = install_dir.join(exe_name);
    if root.exists() {
        return Ok(root);
    }

    // Check one level of subdirectories (e.g. ZIP may contain a top-level folder)
    if let Ok(entries) = fs::read_dir(install_dir) {
        for entry in entries.flatten() {
            let path = entry.path();
            if path.is_dir() {
                let nested = path.join(exe_name);
                if nested.exists() {
                    return Ok(nested);
                }
            }
        }
    }

    Err(InstallError::LauncherNotFound)
}
