//
//  GlassComponents.swift
//  DayPlanner
//
//  Created on 2026-04-06.
//

import SwiftUI

// MARK: - StatusIndicator

struct StatusIndicator: View {
    let status: TodoStatus

    var body: some View {
        switch status {
        case .todo:
            Circle()
                .strokeBorder(AppTheme.statusTodo.opacity(0.7), lineWidth: 1.5)
                .frame(width: 18, height: 18)
        case .doing:
            ZStack {
                Circle()
                    .fill(AppTheme.statusDoing)
                Circle()
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
            }
            .frame(width: 18, height: 18)
            .shadow(color: AppTheme.statusDoing.opacity(0.5), radius: 4, x: 0, y: 1)
        case .done:
            ZStack {
                Circle()
                    .fill(AppTheme.statusDone)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 18, height: 18)
        }
    }
}

// MARK: - GlassTodoRow

struct GlassTodoRow: View {
    let todo: Todo
    let selectedDate: Date
    @EnvironmentObject var viewModel: TodoListViewModel

    private var nextStatus: TodoStatus {
        switch todo.status {
        case .todo: return .doing
        case .doing: return .done
        case .done: return .todo
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            Button {
                viewModel.setStatus(for: todo, to: nextStatus)
            } label: {
                StatusIndicator(status: todo.status)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(todo.title)
                    .font(.system(size: 13, weight: .medium))
                    .strikethrough(todo.status == .done)
                    .foregroundColor(todo.status == .done ? .primary.opacity(0.65) : .primary)

                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.primary.opacity(0.55))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Badges
            HStack(spacing: 8) {
                if todo.status == .doing {
                    Text("DOING")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(0.6)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppTheme.statusDoing.opacity(0.15))
                        .foregroundColor(AppTheme.statusDoing)
                        .clipShape(Capsule())
                }

                if todo.type == .recurring {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.4))
                }

                if !DateService.shared.isToday(selectedDate) {
                    Button {
                        viewModel.moveTodoToToday(todo)
                    } label: {
                        Image(systemName: "arrow.right.to.line")
                            .font(.caption)
                            .foregroundColor(AppTheme.accent)
                    }
                    .buttonStyle(.plain)
                    .help("Move to today")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
        .contextMenu {
            todoContextMenu(todo: todo, viewModel: viewModel)
        }
    }
}

// MARK: - GlassKanbanCard

struct GlassKanbanCard: View {
    let todo: Todo
    @EnvironmentObject var viewModel: TodoListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(todo.status.themeColor)
                    .frame(width: 7, height: 7)
                    .padding(.top, 5)
                Text(todo.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(3)
                    .strikethrough(todo.status == .done)
                    .foregroundColor(todo.status == .done ? .primary.opacity(0.65) : .primary)
                Spacer(minLength: 0)
            }

            if todo.type == .recurring {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 9))
                    Text("Recurring")
                        .font(.system(size: 10, design: .rounded))
                }
                .foregroundColor(.primary.opacity(0.4))
                .padding(.leading, 15)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
        .help(todo.description ?? "")
        .contextMenu {
            todoContextMenu(todo: todo, viewModel: viewModel)
        }
    }
}

// MARK: - Shared Context Menu

@ViewBuilder
private func todoContextMenu(todo: Todo, viewModel: TodoListViewModel) -> some View {
    switch todo.status {
    case .todo:
        Button {
            viewModel.setStatus(for: todo, to: .doing)
        } label: {
            Label("Start", systemImage: "play.fill")
        }
        Button {
            viewModel.setStatus(for: todo, to: .done)
        } label: {
            Label("Complete", systemImage: "checkmark.circle.fill")
        }
    case .doing:
        Button {
            viewModel.setStatus(for: todo, to: .done)
        } label: {
            Label("Complete", systemImage: "checkmark.circle.fill")
        }
        Button {
            viewModel.setStatus(for: todo, to: .todo)
        } label: {
            Label("Reopen", systemImage: "arrow.uturn.backward")
        }
    case .done:
        Button {
            viewModel.setStatus(for: todo, to: .todo)
        } label: {
            Label("Reopen", systemImage: "arrow.uturn.backward")
        }
    }

    Divider()

    Button(role: .destructive) {
        viewModel.deleteTodo(todo)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
