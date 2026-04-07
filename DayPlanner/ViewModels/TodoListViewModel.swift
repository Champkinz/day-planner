//
//  TodoListViewModel.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation
import SwiftUI
import Combine

enum ViewMode: String {
    case list
    case kanban
}

class TodoListViewModel: ObservableObject {
    static let shared = TodoListViewModel()

    @Published var todos: [Todo] = []
    @Published var recurringTodos: [RecurringTodo] = []
    @Published var viewMode: ViewMode = .list

    private let persistenceService = PersistenceService.shared
    private let generationService = TodoGenerationService()
    private let dateService = DateService.shared
    private var dailyRefreshTimer: Timer?

    private init() {
        loadData()
        setupDailyRefresh()
    }

    // MARK: - Data Loading

    func loadData() {
        todos = persistenceService.loadTodos()
        recurringTodos = persistenceService.loadRecurringTodos()

        // Generate missing todos up to today on launch
        generateTodosForToday()
    }

    // MARK: - Todo Operations

    func todos(for date: Date) -> [Todo] {
        todos.filter { dateService.isSameDay($0.date, date) }
            .sorted { todo1, todo2 in
                // Sort: doing first, then todo, then done
                let statusOrder: [TodoStatus] = [.doing, .todo, .done]
                let order1 = statusOrder.firstIndex(of: todo1.status) ?? 0
                let order2 = statusOrder.firstIndex(of: todo2.status) ?? 0
                if order1 != order2 {
                    return order1 < order2
                }
                // Within same status, mandatory before optional
                if todo1.isMandatory != todo2.isMandatory {
                    return todo1.isMandatory && !todo2.isMandatory
                }
                // Then by createdAt
                return todo1.createdAt < todo2.createdAt
            }
    }

    func todos(for date: Date, status: TodoStatus) -> [Todo] {
        todos(for: date).filter { $0.status == status }
    }

    func todosForToday() -> [Todo] {
        todos(for: Date())
    }

    func incompleteCount(for date: Date = Date()) -> Int {
        todos(for: date).filter { $0.status != .done }.count
    }

    func inProgressCount(for date: Date = Date()) -> Int {
        todos(for: date).filter { $0.status == .doing }.count
    }

    func doneCount(for date: Date = Date()) -> Int {
        todos(for: date).filter { $0.status == .done }.count
    }

    func setStatus(for todo: Todo, to status: TodoStatus) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].status = status
            todos[index].completedAt = status == .done ? Date() : nil
            saveTodos()
        }
    }

    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveTodos()
    }

    func deleteTodo(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }

    func moveTodoToToday(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].date = dateService.startOfDay(Date())
            saveTodos()
        }
    }

    // MARK: - Recurring Todo Operations

    func addRecurringTodo(_ recurring: RecurringTodo) {
        recurringTodos.append(recurring)
        saveRecurringTodos()

        // Generate todos for next 30 days
        let endDate = dateService.addDays(30, to: Date())
        let newTodos = generationService.generateMissingTodos(
            recurring: [recurring],
            existing: todos,
            upTo: endDate
        )
        todos.append(contentsOf: newTodos)
        saveTodos()
    }

    func deleteRecurringTodo(_ recurring: RecurringTodo) {
        recurringTodos.removeAll { $0.id == recurring.id }
        saveRecurringTodos()

        // Optionally remove all future generated todos from this recurring
        // (uncomment if you want to delete all associated todos)
        // todos.removeAll { $0.recurringTodoId == recurring.id && $0.date >= Date() }
        // saveTodos()
    }

    func toggleRecurringTodoActive(_ recurring: RecurringTodo) {
        if let index = recurringTodos.firstIndex(where: { $0.id == recurring.id }) {
            recurringTodos[index].isActive.toggle()
            saveRecurringTodos()
        }
    }

    // MARK: - Todo Generation

    func generateTodosForToday() {
        let today = dateService.startOfDay(Date())
        let newTodos = generationService.generateMissingTodos(
            recurring: recurringTodos,
            existing: todos,
            upTo: today
        )

        if !newTodos.isEmpty {
            todos.append(contentsOf: newTodos)
            saveTodos()
        }
    }

    // MARK: - Persistence

    private func saveTodos() {
        persistenceService.saveTodos(todos)
    }

    private func saveRecurringTodos() {
        persistenceService.saveRecurringTodos(recurringTodos)
    }

    // MARK: - Daily Refresh

    private func setupDailyRefresh() {
        // Check every hour for new day
        dailyRefreshTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.generateTodosForToday()
            }
        }
    }

    // MARK: - Cleanup

    func clearAllData() {
        todos.removeAll()
        recurringTodos.removeAll()
        persistenceService.clearAllData()
    }

    deinit {
        dailyRefreshTimer?.invalidate()
    }
}
