//! C-ABI bridge over tokscale-core for the Swift app.
//!
//! Contract: every entry point returns a heap-allocated, NUL-terminated JSON
//! string; the caller must release it with `tb_free`. Entry points are
//! synchronous — Swift calls them from a background thread.

use std::ffi::{c_char, CString};

fn into_raw_json(json: String) -> *mut c_char {
    // A JSON payload should never contain interior NULs; fall back to an
    // error object instead of returning a dangling/null pointer.
    CString::new(json)
        .unwrap_or_else(|_| CString::new(r#"{"ok":false,"err":"interior NUL"}"#).unwrap())
        .into_raw()
}

/// Smoke probe: parse all local clients and report the message count.
/// Proves the staticlib links and tokscale-core can read this machine.
#[no_mangle]
pub extern "C" fn tb_probe() -> *mut c_char {
    let opts = tokscale_core::LocalParseOptions::default();
    let json = match tokscale_core::parse_local_clients(opts) {
        Ok(pm) => format!(r#"{{"ok":true,"messages":{}}}"#, pm.messages.len()),
        Err(e) => serde_json::json!({"ok": false, "err": e}).to_string(),
    };
    into_raw_json(json)
}

/// Release a string returned by any tb_* entry point.
///
/// # Safety
/// `p` must be a pointer previously returned by this library (or null).
#[no_mangle]
pub unsafe extern "C" fn tb_free(p: *mut c_char) {
    if !p.is_null() {
        unsafe {
            let _ = CString::from_raw(p);
        }
    }
}
