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
            HStack(spacing: 12) {
                KanbanColumn(
                    title: "Todo",
                    status: .todo,
                    color: .gray,
                    todos: viewModel.todos(for: selectedDate, status: .todo)
                )
                KanbanColumn(
                    title: "Doing",
                    status: .doing,
                    color: .orange,
                    todos: viewModel.todos(for: selectedDate, status: .doing)
                )
                KanbanColumn(
                    title: "Done",
                    status: .done,
                    color: .green,
                    todos: viewModel.todos(for: selectedDate, status: .done)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)

                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(color.opacity(0.9))

                Text("\(todos.count)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color.opacity(0.6))
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)

            // Cards
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(todos) { todo in
                        GlassKanbanCard(todo: todo)
                            .draggable(todo.id.uuidString)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(isTargeted ? 0.08 : 0.03))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(isTargeted ? 0.2 : 0.08), lineWidth: 1)
                )
        )
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
