//
//  AppDelegate.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var outsideClickMonitor: Any?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(systemSymbolName: "flowchart", accessibilityDescription: "flow")
            statusButton.action = #selector(togglePopover)
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
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
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
}
