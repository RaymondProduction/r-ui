//
//  MacUI.swift
//  MacUIBridge
//
//  Created by Raimond Perminov on 16.06.2025.
//
import AppKit
import Foundation
import ObjectiveC

@MainActor
final class RustBridge {
    static var buttonCallback: (@convention(c) (Int32) -> Void)? = nil

    @objc static func handleButton(_ sender: NSButton) {
        let id = Int32(sender.tag)
        buttonCallback?(id)
    }
}

// Global function for FFI (Foreign Function Interface) to register the callback from Rust
@MainActor
@_cdecl("register_button_callback")
public func register_button_callback(_ cb: @convention(c) @escaping (Int32) -> Void) {
    RustBridge.buttonCallback = cb
}

@MainActor
@_cdecl("show_window_with_buttons")
public func show_window_with_buttons(
    _ c_labels: UnsafePointer<UnsafePointer<CChar>?>,
    _ c_ids: UnsafePointer<Int32>,
    _ count: Int
) {
    var labels: [String] = []
    var ids: [Int32] = []

    for i in 0..<count {
        guard let cStr = c_labels[i] else { continue }
        labels.append(String(cString: cStr))
        ids.append(c_ids[i])
    }

    let app = NSApplication.shared
    app.setActivationPolicy(.regular)

    let window = NSWindow(
        contentRect: NSRect(x: 300, y: 300, width: 400, height: 60 + count * 40),
        styleMask: [.titled, .closable],
        backing: .buffered,
        defer: false
    )
    window.title = "Dynamic Buttons from Rust"

    for i in 0..<labels.count {
        let button = NSButton(
            title: labels[i],
            target: RustBridge.self,
            action: #selector(RustBridge.handleButton(_:))
        )
        button.tag = Int(ids[i])
        button.frame = NSRect(x: 100, y: 40 * i + 10, width: 200, height: 30)
        window.contentView?.addSubview(button)
    }

    window.makeKeyAndOrderFront(nil)

    app.activate(ignoringOtherApps: true)
    app.run()
}
