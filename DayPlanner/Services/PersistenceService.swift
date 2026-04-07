//
//  PersistenceService.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

class PersistenceService {
    static let shared = PersistenceService()

    private let recurringTodosURL: URL
    private let todosURL: URL
    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        // Get Application Support directory
        let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        // Create DayPlanner subdirectory
        let appDirectory = appSupport.appendingPathComponent("DayPlanner")
        try? fileManager.createDirectory(
            at: appDirectory,
            withIntermediateDirectories: true
        )

        // Set file URLs
        recurringTodosURL = appDirectory.appendingPathComponent("recurring_todos.json")
        todosURL = appDirectory.appendingPathComponent("todos.json")

        // Configure encoder/decoder for better readability
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Recurring Todos

    func loadRecurringTodos() -> [RecurringTodo] {
        guard fileManager.fileExists(atPath: recurringTodosURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: recurringTodosURL)
            let todos = try decoder.decode([RecurringTodo].self, from: data)
            return todos
        } catch {
            print("Error loading recurring todos: \(error)")
            return []
        }
    }

    func saveRecurringTodos(_ todos: [RecurringTodo]) {
        do {
            let data = try encoder.encode(todos)
            try data.write(to: recurringTodosURL, options: [.atomic])
        } catch {
            print("Error saving recurring todos: \(error)")
        }
    }

    // MARK: - Legacy Migration

    /// Matches the old Todo format where `isCompleted: Bool` was used instead of `status: TodoStatus`.
    private struct LegacyTodo: Codable {
        let id: UUID
        var title: String
        var description: String?
        var date: Date
        var isCompleted: Bool
        var isMandatory: Bool
        var type: TodoType
        var recurringTodoId: UUID?
        var completedAt: Date?
        var createdAt: Date

        func toTodo() -> Todo {
            Todo(
                id: id,
                title: title,
                description: description,
                date: date,
                status: isCompleted ? .done : .todo,
                isMandatory: isMandatory,
                type: type,
                recurringTodoId: recurringTodoId,
                completedAt: completedAt,
                createdAt: createdAt
            )
        }
    }

    // MARK: - Todos

    func loadTodos() -> [Todo] {
        guard fileManager.fileExists(atPath: todosURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: todosURL)

            // Try decoding with the current format first
            do {
                let todos = try decoder.decode([Todo].self, from: data)
                return todos
            } catch {
                // Fall back to legacy format and migrate
                let legacyTodos = try decoder.decode([LegacyTodo].self, from: data)
                let migratedTodos = legacyTodos.map { $0.toTodo() }
                print("Migrated \(migratedTodos.count) todos from legacy format")
                saveTodos(migratedTodos)
                return migratedTodos
            }
        } catch {
            print("Error loading todos: \(error)")
            return []
        }
    }

    func saveTodos(_ todos: [Todo]) {
        do {
            let data = try encoder.encode(todos)
            try data.write(to: todosURL, options: [.atomic])
        } catch {
            print("Error saving todos: \(error)")
        }
    }

    // MARK: - Utility

    func getStorageDirectory() -> URL {
        return recurringTodosURL.deletingLastPathComponent()
    }

    func clearAllData() {
        try? fileManager.removeItem(at: recurringTodosURL)
        try? fileManager.removeItem(at: todosURL)
    }

    // MARK: - Export / Import

    struct BackupData: Codable {
        let todos: [Todo]
        let recurringTodos: [RecurringTodo]
        let exportedAt: Date
    }

    func exportData() throws -> Data {
        let backup = BackupData(
            todos: loadTodos(),
            recurringTodos: loadRecurringTodos(),
            exportedAt: Date()
        )
        return try encoder.encode(backup)
    }

    func importData(from data: Data) throws -> (todos: Int, recurring: Int) {
        let backup = try decoder.decode(BackupData.self, from: data)
        saveTodos(backup.todos)
        saveRecurringTodos(backup.recurringTodos)
        return (backup.todos.count, backup.recurringTodos.count)
    }
}
