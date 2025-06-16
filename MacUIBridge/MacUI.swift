//
//  MacUI.swift
//  MacUIBridge
//
//  Created by Raimond Perminov on 16.06.2025.
//
import AppKit

@MainActor
@_cdecl("show_mac_window")
public func show_mac_window() {

    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    let window = NSWindow(
        contentRect: NSRect(x: 400, y: 400, width: 400, height: 200),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )
    window.title = "Hello from macOS"
    let label = NSTextField(labelWithString: "This window was called from Rust 🦀")
    label.frame = NSRect(x: 40, y: 80, width: 300, height: 40)
    window.contentView?.addSubview(label)
    window.makeKeyAndOrderFront(nil)

    app.activate(ignoringOtherApps: true)
    app.run()
}
