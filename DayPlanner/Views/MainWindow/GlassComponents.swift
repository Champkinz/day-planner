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
                .strokeBorder(Color.secondary, lineWidth: 1.5)
                .frame(width: 18, height: 18)
        case .doing:
            Circle()
                .fill(Color.orange)
                .overlay(
                    Circle()
                        .strokeBorder(Color.orange, lineWidth: 1.5)
                )
                .frame(width: 18, height: 18)
        case .done:
            Circle()
                .fill(Color.green)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
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
        HStack(spacing: 12) {
            Button {
                viewModel.setStatus(for: todo, to: nextStatus)
            } label: {
                StatusIndicator(status: todo.status)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.status == .done)

                if let description = todo.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Badges
            HStack(spacing: 8) {
                if todo.status == .doing {
                    Text("Doing")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }

                if todo.type == .recurring {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !DateService.shared.isToday(selectedDate) {
                    Button {
                        viewModel.moveTodoToToday(todo)
                    } label: {
                        Image(systemName: "arrow.right.to.line")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .help("Move to today")
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.regularMaterial)
        )
        .opacity(todo.status == .done ? 0.7 : 1.0)
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
        VStack(alignment: .leading, spacing: 6) {
            Text(todo.title)
                .font(.system(size: 13))
                .lineLimit(2)
                .strikethrough(todo.status == .done)

            if todo.type == .recurring {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
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
