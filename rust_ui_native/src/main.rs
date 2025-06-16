use libloading::{Library, Symbol};
use std::ffi::{CString, c_char};

extern "C" fn on_button_pressed() {
    println!("✅ Button was pressed in Swift!");
}

fn main() {
    let lib_path = "./native/libMacUIBridge.dylib";

    let lib = unsafe {
        Library::new(lib_path)
            .expect("Failed to load dylib")
    };

    unsafe {
        // register callback
        let register: Symbol<unsafe extern "C" fn(cb: extern "C" fn())> =
            lib.get(b"register_callback")
                .expect("Function register_callback not found");

        register(on_button_pressed);

        // call window
        let show: Symbol<unsafe extern "C" fn(*const c_char)> =
            lib.get(b"show_mac_window_with_text")
                .expect("Function show_mac_window_with_text not found");

        let message = CString::new("Press the button below 👇").unwrap();
        show(message.as_ptr());
    }
}
