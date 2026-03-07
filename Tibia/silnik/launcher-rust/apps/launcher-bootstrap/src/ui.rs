/// Minimal UI module for the bootstrap launcher.
///
/// Phase 1: console-based output (print to stderr).
/// Phase 2 (BL-05/BL-06): replace with native Win32 window / GTK / TUI.

use std::sync::atomic::{AtomicU8, Ordering};

static LAST_PROGRESS: AtomicU8 = AtomicU8::new(0);

/// Display a status message to the user.
pub fn set_status(msg: &str) {
    eprintln!("[bootstrap] {msg}");
}

/// Update the progress indicator (0–100).
/// Prints only when the percentage actually changes.
pub fn set_progress(pct: u8) {
    let pct = pct.min(100);
    let prev = LAST_PROGRESS.swap(pct, Ordering::Relaxed);
    if pct != prev {
        eprint!("\r[bootstrap] Postęp: {pct:>3}%");
        if pct == 100 {
            eprintln!();
        }
    }
}

/// Show a fatal error to the user and wait for acknowledgement.
pub fn show_error(msg: &str) {
    eprintln!("\n[bootstrap] BŁĄD: {msg}");

    #[cfg(target_os = "windows")]
    {
        // On Windows, show a MessageBox so the user sees the error even if the
        // console closes immediately.
        show_message_box_win(msg);
    }
}

#[cfg(target_os = "windows")]
fn show_message_box_win(msg: &str) {
    use std::ffi::CString;
    // Use raw Win32 API via extern to avoid extra dependencies.
    extern "system" {
        fn MessageBoxA(hwnd: *mut u8, text: *const u8, caption: *const u8, utype: u32) -> i32;
    }
    let text = CString::new(msg).unwrap_or_default();
    let caption = CString::new("SerwerCanary — Bootstrap").unwrap_or_default();
    unsafe {
        MessageBoxA(
            std::ptr::null_mut(),
            text.as_ptr() as *const u8,
            caption.as_ptr() as *const u8,
            0x10, // MB_ICONERROR
        );
    }
}

/// Reset progress counter (useful between stages).
pub fn reset_progress() {
    LAST_PROGRESS.store(0, Ordering::Relaxed);
}
