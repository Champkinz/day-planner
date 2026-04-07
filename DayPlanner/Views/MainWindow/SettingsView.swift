//
//  SettingsView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI
import Sparkle

struct SettingsView: View {
    @StateObject private var launchService = LaunchAtLoginService.shared
    @EnvironmentObject var viewModel: TodoListViewModel
    private let persistenceService = PersistenceService.shared
    let updater: SPUUpdater

    var body: some View {
        TabView {
            generalSettings
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            dataSettings
                .tabItem {
                    Label("Data", systemImage: "externaldrive")
                }

            aboutSettings
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
        .padding()
    }

    private var generalSettings: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $launchService.isEnabled)
                Text(launchService.statusDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Appearance") {
                Text("More settings coming soon...")
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var dataSettings: some View {
        Form {
            Section("Storage") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Location:")
                        .font(.headline)
                    Text(persistenceService.getStorageDirectory().path)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)

                    Button("Open in Finder") {
                        NSWorkspace.shared.open(persistenceService.getStorageDirectory())
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Statistics:")
                        .font(.headline)
                    Text("Total Todos: \(viewModel.todos.count)")
                        .font(.caption)
                    Text("Recurring Todos: \(viewModel.recurringTodos.count)")
                        .font(.caption)
                }
            }

            Section("Danger Zone") {
                Button("Clear All Data") {
                    clearAllData()
                }
                .foregroundColor(.red)
                .disabled(viewModel.todos.isEmpty && viewModel.recurringTodos.isEmpty)
            }
        }
        .formStyle(.grouped)
    }

    private var aboutSettings: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text("Day Planner")
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A simple daily planning app with recurring todos")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Spacer()

            Button("Check for Updates...") {
                updater.checkForUpdates()
            }

            Text("Made with SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func clearAllData() {
        let alert = NSAlert()
        alert.messageText = "Clear All Data?"
        alert.informativeText = "This will permanently delete all todos and recurring todos. This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Clear All Data")

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            viewModel.clearAllData()
        }
    }
}

#Preview {
    SettingsView(updater: SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil).updater)
        .environmentObject(TodoListViewModel.shared)
}
