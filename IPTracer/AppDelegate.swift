//
//  AppDelegate.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover: NSPopover!
    private var outsideClickMonitor: Any?
    
    private lazy var settingsMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit IPTracer", action: #selector(quit(_:)), keyEquivalent: "")
        return menu
    }()
    
    @available(macOS, deprecated: 10.14)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupPopover()
        detectOutsideClick()
    }
    
    @available(macOS, deprecated: 10.14)
    private func setupStatusItem() {
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "flowchart", accessibilityDescription: "flow")
            statusButton.action = #selector(togglePopover)
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 100)
        popover.behavior = .transient
        popover.contentViewController = ViewController()
    }
    
    private func detectOutsideClick() {
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] event in
            guard let self = self, self.popover.isShown else { return }
            let location = event.locationInWindow
            let convertedLocation = self.popover.contentViewController?.view.convert(location, from: nil)
            if !(self.popover.contentViewController?.view.frame.contains(convertedLocation ?? .zero) ?? false) {
                self.popover.performClose(nil)
            }
        }
    }
    
    @available(macOS, deprecated: 10.14)
    @objc private func togglePopover() {
        if let event = NSApp.currentEvent {
            if event.type == NSEvent.EventType.rightMouseUp {
                statusItem.popUpMenu(settingsMenu)
            } else {
                if let button = statusItem.button {
                    if popover.isShown {
                        popover.performClose(nil)
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    }
                }
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc private func quit(_ sender: Any?) {
        NSApplication.shared.terminate(self)
    }
}
