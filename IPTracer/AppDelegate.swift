//
//  AppDelegate.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var popover: NSPopover!
    private var outsideClickMonitor: Any?
    private var settingsMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit IPTracer", action: #selector(quit(_:)), keyEquivalent: "")
        return menu
    }()
    
    @available(macOS, deprecated: 10.14)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "flowchart", accessibilityDescription: "flow")
            statusButton.action = #selector(togglePopover)
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 200, height: 100)
        self.popover.behavior = .transient
        self.popover.contentViewController = ViewController()
        self.detectOutsideClick()
    }
    
    private func detectOutsideClick() {
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
                if let self = self, self.popover.isShown {
                    let location = event.locationInWindow
                    let convertedLocation = self.popover.contentViewController?.view.convert(location, from: nil)
                    if !(self.popover.contentViewController?.view.frame.contains(convertedLocation ?? .zero) ?? false) {
                        self.popover.performClose(nil)
                    }
                }
            }
    }
    
    @available(macOS, deprecated: 10.14)
    @objc func togglePopover() {
        if let event = NSApp.currentEvent {
            if event.type == NSEvent.EventType.rightMouseUp {
                statusItem.popUpMenu(settingsMenu)
            } else {
                if let button = statusItem.button {
                    if popover.isShown {
                        self.popover.performClose(nil)
                    } else {
                        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
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
    
    @objc func quit(_ sender: AnyObject?) {
        NSApplication.shared.terminate(self)
    }
}
