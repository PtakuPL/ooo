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

/// Ask the user where to install. Returns chosen path or default.
///
/// Windows: shows a "Yes/No" MessageBox with default path. If "No",
///          opens a folder picker dialog (SHBrowseForFolderW).
/// Linux:   returns the default path (no GUI available).
pub fn ask_install_dir(prompt_title: &str, prompt_msg: &str) -> PathBuf {
    let default = default_install_dir();

    #[cfg(target_os = "windows")]
    {
        let chosen = win_ask_install_dir(&default, prompt_title, prompt_msg);
        return chosen.unwrap_or(default);
    }

    #[cfg(not(target_os = "windows"))]
    {
        let _ = (prompt_title, prompt_msg);
        default
    }
}

#[cfg(target_os = "windows")]
fn win_ask_install_dir(default: &std::path::Path, title: &str, msg: &str) -> Option<PathBuf> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s).encode_wide().chain(std::iter::once(0)).collect()
    }

    extern "system" {
        fn MessageBoxW(hwnd: *mut u8, text: *const u16, caption: *const u16, utype: u32) -> i32;
    }

    // Ask: "Install to <default>?"  YES=default, NO=pick folder
    let full_msg = format!("{msg}\n\n{}\n\nClick YES to install here, or NO to choose a different folder.", default.display());
    let text_w = to_wide(&full_msg);
    let caption_w = to_wide(title);

    let result = unsafe {
        MessageBoxW(
            std::ptr::null_mut(),
            text_w.as_ptr(),
            caption_w.as_ptr(),
            0x24, // MB_YESNO | MB_ICONQUESTION
        )
    };

    if result == 6 {
        // IDYES
        return Some(default.to_path_buf());
    }

    // User wants to pick a folder
    win_browse_for_folder(title).or_else(|| Some(default.to_path_buf()))
}

#[cfg(target_os = "windows")]
fn win_browse_for_folder(title: &str) -> Option<PathBuf> {
    use std::ffi::OsStr;
    use std::os::windows::ffi::OsStrExt;

    fn to_wide(s: &str) -> Vec<u16> {
        OsStr::new(s).encode_wide().chain(std::iter::once(0)).collect()
    }

    #[repr(C)]
    #[allow(non_snake_case)]
    struct BROWSEINFOW {
        hwndOwner: *mut u8,
        pidlRoot: *mut u8,
        pszDisplayName: *mut u16,
        lpszTitle: *const u16,
        ulFlags: u32,
        lpfn: *mut u8,
        lParam: isize,
        iImage: i32,
    }

    extern "system" {
        fn CoInitializeEx(reserved: *mut u8, co_init: u32) -> i32;
        fn SHBrowseForFolderW(bi: *const BROWSEINFOW) -> *mut u8;
        fn SHGetPathFromIDListW(pidl: *const u8, path: *mut u16) -> i32;
        fn CoTaskMemFree(pv: *mut u8);
    }

    const BIF_RETURNONLYFSDIRS: u32 = 0x0001;
    const BIF_NEWDIALOGSTYLE: u32 = 0x0040;
    const COINIT_APARTMENTTHREADED: u32 = 0x2;

    unsafe { CoInitializeEx(std::ptr::null_mut(), COINIT_APARTMENTTHREADED); }

    let title_w = to_wide(title);
    let mut display_name: Vec<u16> = vec![0u16; 260];

    let bi = BROWSEINFOW {
        hwndOwner: std::ptr::null_mut(),
        pidlRoot: std::ptr::null_mut(),
        pszDisplayName: display_name.as_mut_ptr(),
        lpszTitle: title_w.as_ptr(),
        ulFlags: BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE,
        lpfn: std::ptr::null_mut(),
        lParam: 0,
        iImage: 0,
    };

    let pidl = unsafe { SHBrowseForFolderW(&bi) };
    if pidl.is_null() {
        return None; // User cancelled
    }

    let mut path_buf: Vec<u16> = vec![0u16; 260];
    let ok = unsafe { SHGetPathFromIDListW(pidl, path_buf.as_mut_ptr()) };
    unsafe { CoTaskMemFree(pidl); }

    if ok == 0 {
        return None;
    }

    let len = path_buf.iter().position(|&c| c == 0).unwrap_or(path_buf.len());
    let path_str = String::from_utf16_lossy(&path_buf[..len]);

    if path_str.is_empty() {
        None
    } else {
        Some(PathBuf::from(path_str).join("SerwerCanary"))
    }
}

/// Name of the full launcher executable for the current platform.
pub fn launcher_exe_name() -> &'static str {
    if cfg!(target_os = "windows") {
        "launcher-tauri-windows-x86_64.exe"
    } else {
        "launcher-tauri-linux-x86_64"
    }
}
