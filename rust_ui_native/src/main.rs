use std::ffi::{CString, c_char};
use std::os::raw::c_int;
use libloading::{Library, Symbol};
use std::sync::OnceLock;

// Global variables
static LIB: OnceLock<Library> = OnceLock::new();
static UPDATE_FN: OnceLock<Symbol<'static, unsafe extern "C" fn(c_int, *const c_char)>> = OnceLock::new();
static CREATE_BUTTON_FN: OnceLock<Symbol<'static, unsafe extern "C" fn(c_int, *const c_char, c_int, c_int, c_int, c_int)>> = OnceLock::new();

extern "C" fn on_logged(log: c_int) {
    println!("Log from Swift UI: {}", log);
}

extern "C" fn on_button_clicked(button_id: c_int) {
    println!("🔘 Button ID: {}", button_id);

   let new_title = CString::new("Changed 👈").unwrap();

    if let Some(update) = UPDATE_FN.get() {

        unsafe {
           update(button_id, new_title.as_ptr());
        }
    } else {
        eprintln!("❗ update_button_title ще не готова!");
    }

    if let Some(create_button) = CREATE_BUTTON_FN.get() {
        let new_title = CString::new("YES 👈").unwrap();
        unsafe {
           create_button(4, new_title.as_ptr(), 0,0,200,30)
        }
    }
}

fn main() {
    let lib = unsafe {
    Library::new("./native/libMacUIBridge.dylib")
            .expect("Failed to download dynamic library")
    };
    LIB.set(lib).expect("❌ Failed to save the library");

    let lib_ref = LIB.get().unwrap();

    // create button function
    let create_button: Symbol<unsafe extern "C" fn(c_int, *const c_char, c_int, c_int, c_int,c_int)> =
        unsafe { lib_ref.get(b"create_button").unwrap() };
    CREATE_BUTTON_FN.set(create_button).expect("❌ Failed to save the create_button fn");

    // Button text update function
    let update: Symbol<unsafe extern "C" fn(c_int, *const c_char)> =
        unsafe { lib_ref.get(b"update_button_title").unwrap() };
    UPDATE_FN.set(update).expect("❌ Failed to save the update fn");

    // Registration callback function
    let register: Symbol<unsafe extern "C" fn(cb: extern "C" fn(c_int))> =
        unsafe { lib_ref.get(b"register_button_callback").unwrap() };

    
    // Function for registration log callback
    let registerLog: Symbol<unsafe extern "C" fn(cb: extern "C" fn(c_int))> =
        unsafe { lib_ref.get(b"register_log_callback").unwrap() };

    let show: Symbol<unsafe extern "C" fn(*const *const c_char, *const c_int, usize)> =
        unsafe { lib_ref.get(b"show_window_with_buttons").unwrap() };

    // List of buttons and ids
    let labels = vec!["OK", "Cancel", "Apply"];
    let ids = vec![1, 2, 3];

    let c_labels: Vec<CString> = labels.iter().map(|s| CString::new(*s).unwrap()).collect();
    let c_ptrs: Vec<*const c_char> = c_labels.iter().map(|s| s.as_ptr()).collect();

    unsafe {   
        register(on_button_clicked);
        registerLog(on_logged);
        show(c_ptrs.as_ptr(), ids.as_ptr(), labels.len());
        
       // let new_title = CString::new("YES 👈").unwrap();
       // create_button(4, new_title.as_ptr(), 0,0,20,30)
    }
}
