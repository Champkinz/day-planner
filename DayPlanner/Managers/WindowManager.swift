//
//  WindowManager.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import AppKit
import SwiftUI

class WindowManager {
    static let shared = WindowManager()

    private init() {}

    func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)

        // Find the main window
        if let window = NSApp.windows.first(where: { $0.isMainWindow || $0.title.contains("Day Planner") }) {
            window.makeKeyAndOrderFront(nil)
        } else if let window = NSApp.windows.first {
            // Fallback: show the first window
            window.makeKeyAndOrderFront(nil)
        }
    }

    func centerMainWindow() {
        if let window = NSApp.windows.first(where: { $0.isMainWindow }) {
            window.center()
        }
    }
}
