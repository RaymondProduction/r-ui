use std::ffi::{CString, c_char};
use std::os::raw::c_int;
use libloading::{Library, Symbol};

extern "C" fn on_button_clicked(button_id: c_int) {
    println!("🔘 Button was pressed with ID: {}", button_id);
}

fn main() {
    let lib = unsafe { Library::new("./native/libMacUIBridge.dylib").unwrap() };

    unsafe {
        let register: Symbol<unsafe extern "C" fn(cb: extern "C" fn(c_int))> =
            lib.get(b"register_button_callback").unwrap();
        register(on_button_clicked);

        let show: Symbol<unsafe extern "C" fn(*const *const c_char, *const c_int, usize)> =
            lib.get(b"show_window_with_buttons").unwrap();

        let labels = vec!["OK", "Cancel", "Apply"];
        let ids = vec![1, 2, 3];

        let c_labels: Vec<CString> = labels.iter().map(|s| CString::new(*s).unwrap()).collect();
        let c_ptrs: Vec<*const c_char> = c_labels.iter().map(|s| s.as_ptr()).collect();

        show(c_ptrs.as_ptr(), ids.as_ptr(), labels.len());
    }
}
