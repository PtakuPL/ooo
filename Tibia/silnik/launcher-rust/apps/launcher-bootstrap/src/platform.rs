use std::path::PathBuf;

/// Detected platform identifier sent to the API.
pub fn platform_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "windows"
    } else if cfg!(target_os = "linux") {
        "linux"
    } else {
        "unknown"
    }
}

/// CPU architecture string sent to the API.
pub fn arch_name() -> &'static str {
    if cfg!(target_arch = "x86_64") {
        "x86_64"
    } else if cfg!(target_arch = "aarch64") {
        "arm64"
    } else {
        "unknown"
    }
}

/// Default installation directory for the full launcher.
///
/// Windows: `%LOCALAPPDATA%\SerwerCanary\`
/// Linux:   `~/Games/SerwerCanary/`
pub fn default_install_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        if let Ok(local) = std::env::var("LOCALAPPDATA") {
            return PathBuf::from(local).join("SerwerCanary");
        }
        PathBuf::from(r"C:\SerwerCanary")
    }
    #[cfg(not(target_os = "windows"))]
    {
        if let Ok(home) = std::env::var("HOME") {
            return PathBuf::from(home).join("Games").join("SerwerCanary");
        }
        PathBuf::from("/tmp/SerwerCanary")
    }
}

/// Name of the full launcher executable for the current platform.
pub fn launcher_exe_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "launcher-tauri.exe"
    } else {
        "launcher-tauri"
    }
}
