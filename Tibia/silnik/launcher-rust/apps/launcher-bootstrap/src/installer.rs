use std::fs;
use std::io::{self, Read};
use std::path::{Path, PathBuf};

use crate::i18n;
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
        let s = i18n::t();
        match self {
            Self::Io(e) => write!(f, "{}: {e}", s.error_io),
            Self::Zip(msg) => write!(f, "{}: {msg}", s.error_unzip),
            Self::LauncherNotFound => write!(f, "{}", s.error_launcher_not_found),
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
    ui::set_status(i18n::t().extracting);

    fs::create_dir_all(install_dir)?;

    let file = fs::File::open(zip_path)?;
    let mut archive = zip::ZipArchive::new(file).map_err(|e| InstallError::Zip(e.to_string()))?;

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
    ui::set_status(i18n::t().saving_config);

    let config = serde_json::json!({
        "apiBaseUrl": "https://tibia.reddaxe.pl/apik/v1",
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
            .map_err(|e| InstallError::Io(io::Error::other(e.to_string())))?;
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
    ui::set_status(i18n::t().launching);

    let working_dir = launcher_exe.parent().unwrap_or_else(|| Path::new("."));

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

// ── Uninstall ──

/// Perform a full uninstallation of the launcher from `install_dir`.
pub fn uninstall(install_dir: &Path) -> Result<(), String> {
    let s = i18n::t();

    // Kill running launcher
    ui::set_status(s.uninstall_killing_launcher);
    kill_running_launcher();

    // Remove installed files
    ui::set_status(s.uninstall_removing_files);
    if install_dir.exists() {
        // Remove contents except our own exe (which may be locked if running from install_dir)
        let self_exe = std::env::current_exe().ok();
        remove_dir_contents(install_dir, self_exe.as_deref())
            .map_err(|e| format!("{}: {e}", s.error_io))?;

        // Try to remove the directory itself (may fail if our exe is inside it)
        let _ = fs::remove_dir(install_dir);

        // Schedule cleanup for remaining files on Windows
        #[cfg(target_os = "windows")]
        {
            if install_dir.exists() {
                schedule_self_cleanup(install_dir);
            }
        }
    }

    // Remove language preference so next install starts fresh
    i18n::delete_saved_language();

    // Remove registry entry (Windows only)
    #[cfg(target_os = "windows")]
    {
        ui::set_status(s.uninstall_removing_registry);
        let _ = registry::remove();
    }

    // Remove shortcuts
    ui::set_status(s.uninstall_removing_shortcuts);
    platform::remove_shortcuts();

    Ok(())
}

/// Remove all contents of `dir`, skipping `skip_file` (our own running exe).
fn remove_dir_contents(dir: &Path, skip_file: Option<&Path>) -> Result<(), io::Error> {
    let skip_canonical = skip_file.and_then(|p| p.canonicalize().ok());

    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();

        // Skip our own executable so we don't fail on a locked file
        if let Some(ref skip) = skip_canonical {
            if let Ok(canonical) = path.canonicalize() {
                if canonical == *skip {
                    continue;
                }
            }
        }

        if path.is_dir() {
            let _ = fs::remove_dir_all(&path);
        } else {
            // Retry a few times — the file may still be locked after process kill
            let mut removed = false;
            for _ in 0..5 {
                if fs::remove_file(&path).is_ok() {
                    removed = true;
                    break;
                }
                std::thread::sleep(std::time::Duration::from_millis(500));
            }
            if !removed {
                let _ = fs::remove_file(&path);
            }
        }
    }
    Ok(())
}

/// On Windows: spawn a delayed `cmd` that removes the remaining directory after we exit.
#[cfg(target_os = "windows")]
fn schedule_self_cleanup(install_dir: &Path) {
    use std::os::windows::process::CommandExt;

    let dir_str = install_dir.display().to_string();
    let cmd = format!(
        "ping -n 3 127.0.0.1 >NUL 2>&1 && rmdir /s /q \"{}\"",
        dir_str.replace('"', "")
    );
    let _ = std::process::Command::new("cmd")
        .args(["/C", &cmd])
        .creation_flags(0x08000000) // CREATE_NO_WINDOW
        .spawn();
}

/// Kill any running launcher process and wait for it to terminate.
fn kill_running_launcher() {
    let exe_name = platform::launcher_exe_name();

    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("taskkill")
            .args(["/F", "/IM", exe_name])
            .output();
    }
    #[cfg(not(target_os = "windows"))]
    {
        let _ = std::process::Command::new("pkill")
            .args(["-f", exe_name])
            .output();
    }

    // Wait for the process to fully terminate so file locks are released
    std::thread::sleep(std::time::Duration::from_millis(1500));
}

/// Copy the current bootstrap executable to `install_dir` for use as uninstaller.
pub fn copy_self_to_install_dir(install_dir: &Path) -> Result<(), InstallError> {
    ui::set_status(i18n::t().copying_uninstaller);

    let current_exe = std::env::current_exe().map_err(InstallError::Io)?;

    let target_name = if cfg!(target_os = "windows") {
        "launcher-bootstrap.exe"
    } else {
        "launcher-bootstrap"
    };
    let target = install_dir.join(target_name);

    // Don't overwrite if same file (we may already be running from install_dir)
    if let Ok(canonical_src) = current_exe.canonicalize() {
        if let Ok(canonical_dst) = target.canonicalize() {
            if canonical_src == canonical_dst {
                return Ok(());
            }
        }
    }

    fs::copy(&current_exe, &target)?;
    Ok(())
}

/// Register the uninstaller in Windows Add/Remove Programs.
#[cfg(target_os = "windows")]
pub fn register_uninstaller(install_dir: &Path) -> Result<(), InstallError> {
    ui::set_status(i18n::t().registering_uninstaller);

    registry::register(install_dir)
        .map_err(|e| InstallError::Io(io::Error::new(io::ErrorKind::Other, e)))
}

/// Read the install location from Windows registry. Returns None if not found.
#[cfg(target_os = "windows")]
pub fn read_install_location() -> Option<PathBuf> {
    registry::read_install_location()
}

#[cfg(not(target_os = "windows"))]
pub fn read_install_location() -> Option<PathBuf> {
    None
}

// ── Windows Registry ──

#[cfg(target_os = "windows")]
mod registry {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;
    use std::path::Path;

    const HKEY_CURRENT_USER: isize = 0x80000001_u32 as i32 as isize;
    const KEY_WRITE: u32 = 0x20006;
    const KEY_READ: u32 = 0x20019;
    const REG_SZ: u32 = 1;
    const REG_DWORD: u32 = 4;

    const UNINSTALL_KEY: &str = r"Software\Microsoft\Windows\CurrentVersion\Uninstall\RedDaxe";
    const LAUNCHER_SCHEME_KEY: &str = r"Software\Classes\launcher";
    const LAUNCHER_SCHEME_OPEN_KEY: &str = r"Software\Classes\launcher\shell\open";
    const LAUNCHER_SCHEME_SHELL_KEY: &str = r"Software\Classes\launcher\shell";
    const LAUNCHER_SCHEME_COMMAND_KEY: &str = r"Software\Classes\launcher\shell\open\command";

    #[link(name = "advapi32")]
    extern "system" {
        fn RegCreateKeyExW(
            hKey: isize,
            lpSubKey: *const u16,
            reserved: u32,
            lpClass: *const u16,
            dwOptions: u32,
            samDesired: u32,
            lpSecurityAttributes: *mut u8,
            phkResult: *mut isize,
            lpdwDisposition: *mut u32,
        ) -> i32;
        fn RegSetValueExW(
            hKey: isize,
            lpValueName: *const u16,
            reserved: u32,
            dwType: u32,
            lpData: *const u8,
            cbData: u32,
        ) -> i32;
        fn RegCloseKey(hKey: isize) -> i32;
        fn RegDeleteKeyW(hKey: isize, lpSubKey: *const u16) -> i32;
        fn RegOpenKeyExW(
            hKey: isize,
            lpSubKey: *const u16,
            ulOptions: u32,
            samDesired: u32,
            phkResult: *mut isize,
        ) -> i32;
        fn RegQueryValueExW(
            hKey: isize,
            lpValueName: *const u16,
            lpReserved: *mut u32,
            lpType: *mut u32,
            lpData: *mut u8,
            lpcbData: *mut u32,
        ) -> i32;
    }

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s)
            .encode_wide()
            .chain(std::iter::once(0))
            .collect()
    }

    pub fn register(install_dir: &Path) -> Result<(), String> {
        let key_w = to_wide(UNINSTALL_KEY);
        let mut hkey: isize = 0;
        let mut disposition: u32 = 0;

        let result = unsafe {
            RegCreateKeyExW(
                HKEY_CURRENT_USER,
                key_w.as_ptr(),
                0,
                std::ptr::null(),
                0,
                KEY_WRITE,
                std::ptr::null_mut(),
                &mut hkey,
                &mut disposition,
            )
        };
        if result != 0 {
            return Err(format!("RegCreateKeyExW failed: {result}"));
        }

        let uninstall_exe = install_dir.join("launcher-bootstrap.exe");
        let launcher_exe = install_dir.join(crate::platform::launcher_exe_name());
        let version = env!("CARGO_PKG_VERSION");

        let res = (|| {
            set_string_value(hkey, "DisplayName", "RedDaxe.pl Launcher")?;
            set_string_value(
                hkey,
                "UninstallString",
                &format!("\"{}\" --uninstall", uninstall_exe.display()),
            )?;
            set_string_value(hkey, "InstallLocation", &install_dir.display().to_string())?;
            set_string_value(hkey, "DisplayIcon", &launcher_exe.display().to_string())?;
            set_string_value(hkey, "Publisher", "RedDaxe.pl")?;
            set_string_value(hkey, "DisplayVersion", version)?;
            set_dword_value(hkey, "NoModify", 1)?;
            set_dword_value(hkey, "NoRepair", 1)?;
            register_launcher_scheme(install_dir)?;
            Ok(())
        })();

        unsafe {
            RegCloseKey(hkey);
        }
        res
    }

    fn set_string_value(hkey: isize, name: &str, value: &str) -> Result<(), String> {
        let name_w = to_wide(name);
        let value_w = to_wide(value);
        let data_bytes = value_w.len() * 2;

        let result = unsafe {
            RegSetValueExW(
                hkey,
                name_w.as_ptr(),
                0,
                REG_SZ,
                value_w.as_ptr() as *const u8,
                data_bytes as u32,
            )
        };
        if result != 0 {
            return Err(format!("RegSetValueExW({name}) failed: {result}"));
        }
        Ok(())
    }

    fn set_dword_value(hkey: isize, name: &str, value: u32) -> Result<(), String> {
        let name_w = to_wide(name);
        let data = value.to_le_bytes();

        let result =
            unsafe { RegSetValueExW(hkey, name_w.as_ptr(), 0, REG_DWORD, data.as_ptr(), 4) };
        if result != 0 {
            return Err(format!("RegSetValueExW({name}) failed: {result}"));
        }
        Ok(())
    }

    pub fn remove() -> Result<(), String> {
        delete_key(UNINSTALL_KEY)?;
        delete_key(LAUNCHER_SCHEME_COMMAND_KEY)?;
        delete_key(LAUNCHER_SCHEME_OPEN_KEY)?;
        delete_key(LAUNCHER_SCHEME_SHELL_KEY)?;
        delete_key(LAUNCHER_SCHEME_KEY)?;
        Ok(())
    }

    fn register_launcher_scheme(install_dir: &Path) -> Result<(), String> {
        let launcher_exe = install_dir.join(crate::platform::launcher_exe_name());
        let scheme_hkey = create_key(LAUNCHER_SCHEME_KEY)?;
        let command_hkey = create_key(LAUNCHER_SCHEME_COMMAND_KEY)?;

        let result = (|| {
            set_string_value(scheme_hkey, "", "URL:RedDaxe Launcher")?;
            set_string_value(scheme_hkey, "URL Protocol", "")?;
            set_string_value(
                command_hkey,
                "",
                &format!("\"{}\" \"%1\"", launcher_exe.display()),
            )?;
            Ok(())
        })();

        unsafe {
            RegCloseKey(command_hkey);
            RegCloseKey(scheme_hkey);
        }

        result
    }

    fn create_key(path: &str) -> Result<isize, String> {
        let key_w = to_wide(path);
        let mut hkey: isize = 0;
        let mut disposition: u32 = 0;

        let result = unsafe {
            RegCreateKeyExW(
                HKEY_CURRENT_USER,
                key_w.as_ptr(),
                0,
                std::ptr::null(),
                0,
                KEY_WRITE,
                std::ptr::null_mut(),
                &mut hkey,
                &mut disposition,
            )
        };
        if result != 0 {
            return Err(format!("RegCreateKeyExW failed: {result}"));
        }

        Ok(hkey)
    }

    fn delete_key(path: &str) -> Result<(), String> {
        let key_w = to_wide(path);
        let result = unsafe { RegDeleteKeyW(HKEY_CURRENT_USER, key_w.as_ptr()) };
        if result != 0 && result != 2 {
            return Err(format!("RegDeleteKeyW failed: {result}"));
        }
        Ok(())
    }

    pub fn read_install_location() -> Option<std::path::PathBuf> {
        let key_w = to_wide(UNINSTALL_KEY);
        let mut hkey: isize = 0;

        let result =
            unsafe { RegOpenKeyExW(HKEY_CURRENT_USER, key_w.as_ptr(), 0, KEY_READ, &mut hkey) };
        if result != 0 {
            return None;
        }

        let name_w = to_wide("InstallLocation");
        let mut data: Vec<u8> = vec![0u8; 520]; // MAX_PATH * 2
        let mut data_size: u32 = data.len() as u32;
        let mut value_type: u32 = 0;

        let result = unsafe {
            RegQueryValueExW(
                hkey,
                name_w.as_ptr(),
                std::ptr::null_mut(),
                &mut value_type,
                data.as_mut_ptr(),
                &mut data_size,
            )
        };

        unsafe {
            RegCloseKey(hkey);
        }

        if result != 0 || value_type != REG_SZ {
            return None;
        }

        let wide_len = (data_size as usize) / 2;
        let wide: &[u16] =
            unsafe { std::slice::from_raw_parts(data.as_ptr() as *const u16, wide_len) };
        let len = wide.iter().position(|&c| c == 0).unwrap_or(wide.len());
        let path_str = String::from_utf16_lossy(&wide[..len]);

        if path_str.is_empty() {
            None
        } else {
            Some(std::path::PathBuf::from(path_str))
        }
    }
}
