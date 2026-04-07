//
//  SettingsView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI
import UniformTypeIdentifiers
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

            Section("Backup") {
                HStack(spacing: 12) {
                    Button("Export Data...") {
                        exportData()
                    }

                    Button("Import Data...") {
                        importData()
                    }
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
        VStack(spacing: 16) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
            }

            Text("DayPlanner")
                .font(.title)
                .fontWeight(.bold)

            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A minimal daily planner with list and kanban views, recurring todos, and menu bar access.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 10) {
                Button("Check for Updates...") {
                    updater.checkForUpdates()
                }

                HStack(spacing: 16) {
                    Button("GitHub") {
                        NSWorkspace.shared.open(URL(string: "https://github.com/Champkinz/day-planner")!)
                    }
                    .buttonStyle(.link)

                    Button("Report a Bug") {
                        NSWorkspace.shared.open(URL(string: "https://github.com/Champkinz/day-planner/issues/new")!)
                    }
                    .buttonStyle(.link)
                }
                .font(.caption)
            }

            Text("Made by Charana")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "DayPlanner-Backup.json"
        panel.title = "Export DayPlanner Data"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let data = try persistenceService.exportData()
            try data.write(to: url, options: .atomic)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Export Failed"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    private func importData() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.title = "Import DayPlanner Data"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let confirm = NSAlert()
        confirm.messageText = "Import Data?"
        confirm.informativeText = "This will replace all existing todos and recurring todos with the imported data."
        confirm.alertStyle = .warning
        confirm.addButton(withTitle: "Import")
        confirm.addButton(withTitle: "Cancel")

        guard confirm.runModal() == .alertFirstButtonReturn else { return }

        do {
            let data = try Data(contentsOf: url)
            let counts = try persistenceService.importData(from: data)
            viewModel.loadData()

            let success = NSAlert()
            success.messageText = "Import Successful"
            success.informativeText = "Imported \(counts.todos) todos and \(counts.recurring) recurring todos."
            success.runModal()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Import Failed"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
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
