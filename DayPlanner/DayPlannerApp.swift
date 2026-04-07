//
//  DayPlannerApp.swift
//  DayPlanner
//
//  Created by Charana Amarasekara on 2026-01-01.
//

import SwiftUI
import Combine
import Sparkle

@main
struct DayPlannerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = TodoListViewModel.shared
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    var body: some Scene {
        // Main window
        WindowGroup {
            MainWindowView()
                .frame(minWidth: 600, minHeight: 400)
                .environmentObject(viewModel)
        }
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }

        // Settings window
        Settings {
            SettingsView(updater: updaterController.updater)
                .environmentObject(viewModel)
        }
    }
}

struct CheckForUpdatesView: View {
    @ObservedObject private var checkForUpdatesViewModel: CheckForUpdatesViewModel
    let updater: SPUUpdater

    init(updater: SPUUpdater) {
        self.updater = updater
        self.checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        Button("Check for Updates...") {
            updater.checkForUpdates()
        }
        .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
    }
}

final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false
    private var cancellable: Any?

    init(updater: SPUUpdater) {
        cancellable = updater.publisher(for: \.canCheckForUpdates)
            .assign(to: \.canCheckForUpdates, on: self)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    var windowManager: WindowManager?
    private let viewModel = TodoListViewModel.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize menu bar
        menuBarManager = MenuBarManager(viewModel: viewModel)

        // Initialize window manager
        windowManager = WindowManager.shared

        // Generate missing todos for today on launch
        Task { @MainActor in
            viewModel.generateTodosForToday()

            // Update menu bar badge
            menuBarManager?.updateBadge()
        }

        // Optional: Center the main window on first launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.windowManager?.centerMainWindow()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // If no windows are visible, show the main window
            windowManager?.showMainWindow()
        }
        return true
    }
}
