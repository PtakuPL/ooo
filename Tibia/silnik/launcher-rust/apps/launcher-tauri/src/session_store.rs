//! Persistent launcher session storage.
//!
//! The WebView must not persist bearer session tokens in browser storage.
//! This module keeps the launcher session on the Rust side.
//! On Windows the session blob is protected with DPAPI.
//! On other targets it falls back to a launcher-owned file with restrictive permissions.

use std::path::{Path, PathBuf};

const SESSION_STORE_FILENAME: &str = ".launcher_session.bin";

pub fn load_session_key(launcher_data: &Path) -> Result<Option<String>, String> {
    let path = session_store_path(launcher_data);
    if !path.exists() {
        return Ok(None);
    }

    let encrypted = std::fs::read(&path)
        .map_err(|e| format!("Nie mozna odczytac session store: {e}"))?;
    if encrypted.is_empty() {
        clear_session_key(launcher_data)?;
        return Ok(None);
    }

    let raw = unprotect_bytes(&encrypted)?;
    let text = String::from_utf8(raw)
        .map_err(|e| format!("Session store nie jest poprawnym UTF-8: {e}"))?;
    let Some(clean) = sanitize_session_key(&text)? else {
        clear_session_key(launcher_data)?;
        return Ok(None);
    };

    Ok(Some(clean))
}

pub fn store_session_key(launcher_data: &Path, session_key: &str) -> Result<String, String> {
    let Some(clean) = sanitize_session_key(session_key)? else {
        clear_session_key(launcher_data)?;
        return Ok(String::new());
    };

    std::fs::create_dir_all(launcher_data)
        .map_err(|e| format!("Nie mozna utworzyc katalogu session store: {e}"))?;

    let path = session_store_path(launcher_data);
    let encrypted = protect_bytes(clean.as_bytes())?;
    std::fs::write(&path, encrypted)
        .map_err(|e| format!("Nie mozna zapisac session store: {e}"))?;
    apply_restrictive_permissions(&path)?;

    Ok(clean)
}

pub fn clear_session_key(launcher_data: &Path) -> Result<(), String> {
    let path = session_store_path(launcher_data);
    match std::fs::remove_file(&path) {
        Ok(()) => Ok(()),
        Err(err) if err.kind() == std::io::ErrorKind::NotFound => Ok(()),
        Err(err) => Err(format!("Nie mozna usunac session store: {err}")),
    }
}

fn sanitize_session_key(value: &str) -> Result<Option<String>, String> {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        return Ok(None);
    }
    if trimmed.len() > 256 {
        return Err("sessionKey jest zbyt dlugi.".to_string());
    }
    Ok(Some(trimmed.to_string()))
}

fn session_store_path(launcher_data: &Path) -> PathBuf {
    launcher_data.join(SESSION_STORE_FILENAME)
}

#[cfg(unix)]
fn apply_restrictive_permissions(path: &Path) -> Result<(), String> {
    use std::os::unix::fs::PermissionsExt;

    std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o600))
        .map_err(|e| format!("Nie mozna ustawic uprawnien session store: {e}"))
}

#[cfg(not(unix))]
fn apply_restrictive_permissions(_path: &Path) -> Result<(), String> {
    Ok(())
}

#[cfg(target_os = "windows")]
fn protect_bytes(plaintext: &[u8]) -> Result<Vec<u8>, String> {
    windows_dpapi_protect(plaintext)
}

#[cfg(not(target_os = "windows"))]
fn protect_bytes(plaintext: &[u8]) -> Result<Vec<u8>, String> {
    Ok(plaintext.to_vec())
}

#[cfg(target_os = "windows")]
fn unprotect_bytes(ciphertext: &[u8]) -> Result<Vec<u8>, String> {
    windows_dpapi_unprotect(ciphertext)
}

#[cfg(not(target_os = "windows"))]
fn unprotect_bytes(ciphertext: &[u8]) -> Result<Vec<u8>, String> {
    Ok(ciphertext.to_vec())
}

#[cfg(target_os = "windows")]
fn windows_dpapi_protect(plaintext: &[u8]) -> Result<Vec<u8>, String> {
    use std::ffi::c_void;

    const CRYPTPROTECT_UI_FORBIDDEN: u32 = 0x1;

    #[repr(C)]
    struct DataBlob {
        cb_data: u32,
        pb_data: *mut u8,
    }

    #[link(name = "Crypt32")]
    extern "system" {
        fn CryptProtectData(
            data_in: *mut DataBlob,
            data_descr: *const u16,
            optional_entropy: *mut DataBlob,
            reserved: *mut c_void,
            prompt_struct: *mut c_void,
            flags: u32,
            data_out: *mut DataBlob,
        ) -> i32;
    }

    #[link(name = "Kernel32")]
    extern "system" {
        fn LocalFree(mem: *mut c_void) -> *mut c_void;
    }

    if plaintext.is_empty() {
        return Ok(Vec::new());
    }

    let mut input = DataBlob {
        cb_data: plaintext.len() as u32,
        pb_data: plaintext.as_ptr() as *mut u8,
    };
    let mut output = DataBlob {
        cb_data: 0,
        pb_data: std::ptr::null_mut(),
    };

    let ok = unsafe {
        CryptProtectData(
            &mut input,
            std::ptr::null(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            CRYPTPROTECT_UI_FORBIDDEN,
            &mut output,
        )
    };
    if ok == 0 {
        return Err(format!(
            "DPAPI protect failed: {}",
            std::io::Error::last_os_error()
        ));
    }

    let bytes = unsafe { std::slice::from_raw_parts(output.pb_data, output.cb_data as usize).to_vec() };
    unsafe {
        LocalFree(output.pb_data as *mut c_void);
    }
    Ok(bytes)
}

#[cfg(target_os = "windows")]
fn windows_dpapi_unprotect(ciphertext: &[u8]) -> Result<Vec<u8>, String> {
    use std::ffi::c_void;

    const CRYPTPROTECT_UI_FORBIDDEN: u32 = 0x1;

    #[repr(C)]
    struct DataBlob {
        cb_data: u32,
        pb_data: *mut u8,
    }

    #[link(name = "Crypt32")]
    extern "system" {
        fn CryptUnprotectData(
            data_in: *mut DataBlob,
            data_descr: *mut *mut u16,
            optional_entropy: *mut DataBlob,
            reserved: *mut c_void,
            prompt_struct: *mut c_void,
            flags: u32,
            data_out: *mut DataBlob,
        ) -> i32;
    }

    #[link(name = "Kernel32")]
    extern "system" {
        fn LocalFree(mem: *mut c_void) -> *mut c_void;
    }

    if ciphertext.is_empty() {
        return Ok(Vec::new());
    }

    let mut input = DataBlob {
        cb_data: ciphertext.len() as u32,
        pb_data: ciphertext.as_ptr() as *mut u8,
    };
    let mut output = DataBlob {
        cb_data: 0,
        pb_data: std::ptr::null_mut(),
    };

    let ok = unsafe {
        CryptUnprotectData(
            &mut input,
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            std::ptr::null_mut(),
            CRYPTPROTECT_UI_FORBIDDEN,
            &mut output,
        )
    };
    if ok == 0 {
        return Err(format!(
            "DPAPI unprotect failed: {}",
            std::io::Error::last_os_error()
        ));
    }

    let bytes = unsafe { std::slice::from_raw_parts(output.pb_data, output.cb_data as usize).to_vec() };
    unsafe {
        LocalFree(output.pb_data as *mut c_void);
    }
    Ok(bytes)
}
