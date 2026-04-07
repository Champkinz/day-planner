//
//  MenuBarManager.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import AppKit
import SwiftUI

class MenuBarManager {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let viewModel: TodoListViewModel

    init(viewModel: TodoListViewModel = .shared) {
        self.viewModel = viewModel
        setupMenuBar()
        setupObservers()
    }

    private func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }

        // Set icon
        if let image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Day Planner") {
            button.image = image
        }

        // Set action
        button.action = #selector(togglePopover)
        button.target = self

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 360, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(viewModel)
        )

        // Update badge initially
        updateBadge()
    }

    private func setupObservers() {
        // Observe changes to todos to update badge
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateBadge),
            name: NSNotification.Name("TodosChanged"),
            object: nil
        )
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Activate the app to bring popover to front
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    @objc func updateBadge() {
        let incompleteMandatory = viewModel.incompleteCount()

        guard let button = statusItem?.button else { return }

        // Update button title (badge count)
        if incompleteMandatory > 0 {
            // Show count next to icon
            button.title = " \(incompleteMandatory)"
        } else {
            button.title = ""
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}
