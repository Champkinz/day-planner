//
//  MenuBarView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var selectedDate = Date()
    @AppStorage("isDarkMode") private var isDarkMode = false
    private let dateService = DateService.shared

    var todosForSelectedDate: [Todo] {
        viewModel.todos(for: selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Todo List
            todoList

            Divider()

            // Footer
            footer
        }
        .frame(width: 360, height: 500)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private var header: some View {
        HStack(spacing: 10) {
            // Previous day
            Button {
                selectedDate = dateService.addDays(-1, to: selectedDate)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Previous day")

            // Date label (tappable to open picker)
            Text(dateService.formatRelativeDate(selectedDate))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .overlay {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .blendMode(.destinationOver)
                        .opacity(0.015)
                }

            // Next day
            Button {
                selectedDate = dateService.addDays(1, to: selectedDate)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Next day")

            Spacer()

            // Dark mode toggle
            Button(action: { isDarkMode.toggle() }) {
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Toggle dark mode")

            // Open Main Window Button
            Button(action: openMainWindow) {
                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help("Open Main Window")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var todoList: some View {
        ScrollView {
            if todosForSelectedDate.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No todos for this day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(todosForSelectedDate) { todo in
                        MenuBarTodoItemView(todo: todo)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private var footer: some View {
        HStack {
            // Quick Stats
            let completed = todosForSelectedDate.filter { $0.status == .done }.count
            let total = todosForSelectedDate.count

            if total > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("\(completed)/\(total)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Quit Button
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)

        // Find and show the main window
        if let window = NSApp.windows.first(where: { $0.title == "Day Planner" || $0.isMainWindow }) {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

struct MenuBarTodoItemView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    let todo: Todo

    private var nextStatus: TodoStatus {
        switch todo.status {
        case .todo: return .doing
        case .doing: return .done
        case .done: return .todo
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status Indicator (tap to cycle)
            Button(action: {
                viewModel.setStatus(for: todo, to: nextStatus)
            }) {
                StatusIndicator(status: todo.status)
            }
            .buttonStyle(.plain)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .font(.system(size: 14))
                    .strikethrough(todo.status == .done)
                    .foregroundColor(todo.status == .done ? .secondary : .primary)

                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Badges
            HStack(spacing: 4) {
                if todo.status == .doing {
                    Text("Doing")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(4)
                }

                if todo.type == .recurring {
                    Image(systemName: "repeat")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .cornerRadius(8)
        .padding(.horizontal, 8)
        .contentShape(Rectangle())
        .contextMenu {
            switch todo.status {
            case .todo:
                Button("Start") {
                    viewModel.setStatus(for: todo, to: .doing)
                }
                Button("Complete") {
                    viewModel.setStatus(for: todo, to: .done)
                }
            case .doing:
                Button("Complete") {
                    viewModel.setStatus(for: todo, to: .done)
                }
                Button("Reopen") {
                    viewModel.setStatus(for: todo, to: .todo)
                }
            case .done:
                Button("Reopen") {
                    viewModel.setStatus(for: todo, to: .todo)
                }
            }

            Divider()

            Button("Delete", role: .destructive) {
                viewModel.deleteTodo(todo)
            }
        }
    }
}

#Preview {
    MenuBarView()
        .environmentObject(TodoListViewModel.shared)
}
