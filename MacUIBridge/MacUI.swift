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
    static var logCallback: (@convention(c) (Int32) -> Void)? = nil
    static var buttonMap: [Int32: NSButton] = [:]
    static var windowMap: [Int32: NSWindow] = [:]
    //static var idButtonCounter: Int32 = 0
    
    @objc static func handleButton(_ sender: NSButton) {
        let id = Int32(sender.tag)
        buttonCallback?(id)
    }
    
    @objc static func handleLog(_ log: Int32) {
        logCallback?(log);
    }
}

@MainActor
@_cdecl("create_button")
public func create_button(_ id: Int32,
                          _ c_str: UnsafePointer<CChar>,
                          _ x_int: Int32,
                          _ y_int: Int32,
                          _ width_int: Int32,
                          _ height_int: Int32) {
    let title = String(cString: c_str)
    
    guard let window = RustBridge.windowMap[0] else { return }
    
    RustBridge.handleLog(2)
    
    let button = NSButton(
        title: title,
        target: RustBridge.self,
        action: #selector(RustBridge.handleButton(_:))
    )
    button.tag = Int(id)
    RustBridge.buttonMap[id] = button
    button.frame = NSRect(x: Int(x_int), y: Int(y_int), width: Int(width_int), height: Int(height_int))
    window.contentView?.addSubview(button)
}

@MainActor
@_cdecl("update_button_title")
public func update_button_title(_ id: Int32, _ c_str: UnsafePointer<CChar>) {
    let newTitle = String(cString: c_str)
    guard let button = RustBridge.buttonMap[id] else { return }
    button.title = newTitle
}

// Global function for FFI (Foreign Function Interface) to register the callback from Rust
@MainActor
@_cdecl("register_log_callback")
public func register_log_callback(_ cb: @convention(c) @escaping (Int32) -> Void) {
    RustBridge.logCallback = cb
}

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
    
    RustBridge.handleLog(0)

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
        RustBridge.buttonMap[ids[i]] = button
        button.frame = NSRect(x: 100, y: 40 * i + 10, width: 200, height: 30)
        RustBridge.windowMap[0] = window
        window.contentView?.addSubview(button)
    }

    window.makeKeyAndOrderFront(nil)

    app.activate(ignoringOtherApps: true)
    app.run()
}
