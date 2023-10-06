//
//  main.swift
//  IPTracer
//
//  Created by Dominik Rudzki on 06/10/2023.
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
