use libloading::{Library, Symbol};
use std::{ffi::CString, os::raw::c_char};

fn main() {
    let lib_path = "./native/libMacUIBridge.dylib";

    let lib = unsafe {
        Library::new(lib_path)
            .expect("Failed to load dylib")
    };

    let message = CString::new("Hello from Rust! Raymond 🎯").unwrap();

    unsafe {
        let show_window_with_text: Symbol<unsafe extern "C" fn(*const c_char)> =
            lib.get(b"show_mac_window_with_text")
               .expect("❌ Function show_mac_window not found");

        show_window_with_text(message.as_ptr());
    }
}
