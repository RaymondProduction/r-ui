use libloading::{Library, Symbol};
use std::{thread, time::Duration};

fn main() {
    //             "./native/libMacUIBridge.dylib";
    let lib_path = "./native/libGtkUIBridge.so";

    let lib = unsafe {
        Library::new(lib_path)
            .expect("❌ Failed to load dylib")
    };

    unsafe {
        let show_window: Symbol<unsafe extern "C" fn()> =
            lib.get(b"show_window")
               .expect("❌ Function show_mac_window not found");

        show_window();
    }

    thread::sleep(Duration::from_secs(30));
}
