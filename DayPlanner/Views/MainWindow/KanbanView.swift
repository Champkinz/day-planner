//
//  KanbanView.swift
//  DayPlanner
//
//  Created on 2026-04-06.
//

import SwiftUI

struct KanbanView: View {
    let selectedDate: Date
    @EnvironmentObject var viewModel: TodoListViewModel

    var body: some View {
        let todosForDay = viewModel.todos(for: selectedDate)

        if todosForDay.isEmpty {
            ContentUnavailableView {
                Label("No todos for this day", systemImage: "rectangle.3.group")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            HStack(spacing: 20) {
                KanbanColumn(
                    title: "Todo",
                    status: .todo,
                    color: AppTheme.statusTodo,
                    todos: viewModel.todos(for: selectedDate, status: .todo)
                )
                KanbanColumn(
                    title: "Doing",
                    status: .doing,
                    color: AppTheme.statusDoing,
                    todos: viewModel.todos(for: selectedDate, status: .doing)
                )
                KanbanColumn(
                    title: "Done",
                    status: .done,
                    color: AppTheme.statusDone,
                    todos: viewModel.todos(for: selectedDate, status: .done)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

struct KanbanColumn: View {
    let title: String
    let status: TodoStatus
    let color: Color
    let todos: [Todo]
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .shadow(color: color.opacity(0.5), radius: 3, y: 1)

                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.8)
                    .foregroundColor(color)

                Spacer()

                Text("\(todos.count)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.primary.opacity(0.45))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(
                        Capsule().fill(color.opacity(0.12))
                    )
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            // Cards
            ScrollView {
                LazyVStack(spacing: 8) {
                    if todos.isEmpty {
                        VStack(spacing: 6) {
                            Image(systemName: "tray")
                                .font(.system(size: 22))
                                .foregroundColor(.primary.opacity(0.18))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    Color.primary.opacity(0.08),
                                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                                )
                        )
                    } else {
                        ForEach(todos) { todo in
                            GlassKanbanCard(todo: todo)
                                .draggable(todo.id.uuidString)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(isTargeted ? 0.10 : 0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            color.opacity(isTargeted ? 0.35 : 0.10),
                            lineWidth: isTargeted ? 1.5 : 1
                        )
                )
                .shadow(
                    color: color.opacity(isTargeted ? 0.18 : 0),
                    radius: 16,
                    y: 4
                )
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isTargeted)
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first,
                  let uuid = UUID(uuidString: idString),
                  let todo = viewModel.todos.first(where: { $0.id == uuid }) else {
                return false
            }
            viewModel.setStatus(for: todo, to: status)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }
}
