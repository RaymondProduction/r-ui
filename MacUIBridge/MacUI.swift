//
//  MacUI.swift
//  MacUIBridge
//
//  Created by Raimond Perminov on 16.06.2025.
//
import AppKit

@MainActor
final class RustBridge {
    static var rustCallback: (@convention(c) () -> Void)? = nil

    @objc static func buttonClicked() {
        rustCallback?()
    }
}

// Global function for FFI (Foreign Function Interface) to register the callback from Rust
@MainActor
@_cdecl("register_callback")
public func register_callback(_ callback: @convention(c) @escaping () -> Void) {
    RustBridge.rustCallback = callback
}

@MainActor
@_cdecl("show_mac_window_with_text")
public func show_mac_window_with_text(_ c_str: UnsafePointer<CChar>) {
    let text = String(cString: c_str)

    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    let window = NSWindow(
        contentRect: NSRect(x: 400, y: 400, width: 400, height: 200),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )
    window.title = "Message from Rust"
    
    let label = NSTextField(labelWithString: text)
    label.frame = NSRect(x: 40, y: 80, width: 300, height: 40)
    window.contentView?.addSubview(label)
 
    // Add a button:
    let button = NSButton(title: "Press me", target: RustBridge.self, action: #selector(RustBridge.buttonClicked))
    button.frame = NSRect(x: 100, y: 30, width: 200, height: 30)
    window.contentView?.addSubview(button)
 
    window.makeKeyAndOrderFront(nil)

    app.activate(ignoringOtherApps: true)
    app.run()
}
