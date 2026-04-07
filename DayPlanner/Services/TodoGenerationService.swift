//
//  TodoGenerationService.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

class TodoGenerationService {
    private let dateService = DateService.shared
    private let calendar = Calendar.current

    // MARK: - Main Generation Logic

    /// Check if a recurring todo should generate an instance on a given date
    func shouldGenerateTodo(recurring: RecurringTodo, for date: Date) -> Bool {
        // Check if recurring todo is active
        guard recurring.isActive else { return false }

        let checkDate = dateService.startOfDay(date)
        let startDate = dateService.startOfDay(recurring.startDate)

        // Check if date is before start date
        if checkDate < startDate {
            return false
        }

        // Check if date is after end date (if set)
        if let endDate = recurring.endDate {
            let endOfDay = dateService.startOfDay(endDate)
            if checkDate > endOfDay {
                return false
            }
        }

        // Check recurrence pattern
        return matchesRecurrencePattern(recurring.recurrencePattern, date: checkDate, startDate: startDate)
    }

    /// Generate todos from recurring templates for a specific date range
    func generateTodos(
        from recurringTodos: [RecurringTodo],
        for dateRange: ClosedRange<Date>
    ) -> [Todo] {
        var generatedTodos: [Todo] = []

        let dates = dateService.dateRange(from: dateRange.lowerBound, to: dateRange.upperBound)

        for date in dates {
            for recurring in recurringTodos {
                if shouldGenerateTodo(recurring: recurring, for: date) {
                    let todo = createTodoInstance(from: recurring, for: date)
                    generatedTodos.append(todo)
                }
            }
        }

        return generatedTodos
    }

    /// Generate missing todos (not already in existing todos)
    func generateMissingTodos(
        recurring: [RecurringTodo],
        existing: [Todo],
        upTo endDate: Date
    ) -> [Todo] {
        // Determine the earliest start date
        let earliestStart = recurring
            .map { $0.startDate }
            .min() ?? Date()

        let startDate = dateService.startOfDay(earliestStart)
        let end = dateService.startOfDay(endDate)

        // Generate all potential todos
        let allPotentialTodos = generateTodos(
            from: recurring,
            for: startDate...end
        )

        // Filter out ones that already exist
        let existingKeys = Set(existing.map { makeTodoKey(date: $0.date, recurringId: $0.recurringTodoId) })

        let missingTodos = allPotentialTodos.filter { todo in
            let key = makeTodoKey(date: todo.date, recurringId: todo.recurringTodoId)
            return !existingKeys.contains(key)
        }

        return missingTodos
    }

    // MARK: - Private Helpers

    private func matchesRecurrencePattern(
        _ pattern: RecurrencePattern,
        date: Date,
        startDate: Date
    ) -> Bool {
        switch pattern.type {
        case .daily:
            return matchesDailyPattern(pattern, date: date, startDate: startDate)
        case .weekly:
            return matchesWeeklyPattern(pattern, date: date, startDate: startDate)
        case .monthly:
            return matchesMonthlyPattern(pattern, date: date, startDate: startDate)
        case .custom:
            return matchesCustomPattern(pattern, date: date, startDate: startDate)
        }
    }

    private func matchesDailyPattern(_ pattern: RecurrencePattern, date: Date, startDate: Date) -> Bool {
        let daysDiff = dateService.daysBetween(startDate, date)
        return daysDiff >= 0 && daysDiff % pattern.interval == 0
    }

    private func matchesWeeklyPattern(_ pattern: RecurrencePattern, date: Date, startDate: Date) -> Bool {
        guard let daysOfWeek = pattern.daysOfWeek, !daysOfWeek.isEmpty else {
            return false
        }

        // Check if the day of week matches
        let weekday = dateService.weekday(of: date)
        guard daysOfWeek.contains(weekday) else {
            return false
        }

        // Check interval (every N weeks)
        if pattern.interval > 1 {
            let weeksDiff = calendar.dateComponents([.weekOfYear], from: startDate, to: date).weekOfYear ?? 0
            return weeksDiff >= 0 && weeksDiff % pattern.interval == 0
        }

        return true
    }

    private func matchesMonthlyPattern(_ pattern: RecurrencePattern, date: Date, startDate: Date) -> Bool {
        guard let targetDay = pattern.dayOfMonth else {
            return false
        }

        let dayOfMonth = dateService.dayOfMonth(of: date)
        guard dayOfMonth == targetDay else {
            return false
        }

        // Check interval (every N months)
        if pattern.interval > 1 {
            let monthsDiff = calendar.dateComponents([.month], from: startDate, to: date).month ?? 0
            return monthsDiff >= 0 && monthsDiff % pattern.interval == 0
        }

        return true
    }

    private func matchesCustomPattern(_ pattern: RecurrencePattern, date: Date, startDate: Date) -> Bool {
        // For now, custom patterns use daily logic
        // Can be extended in the future for more complex patterns
        return matchesDailyPattern(pattern, date: date, startDate: startDate)
    }

    private func createTodoInstance(from recurring: RecurringTodo, for date: Date) -> Todo {
        Todo(
            title: recurring.title,
            description: recurring.description,
            date: dateService.startOfDay(date),
            status: .todo,
            isMandatory: recurring.isMandatory,
            type: .recurring,
            recurringTodoId: recurring.id
        )
    }

    private func makeTodoKey(date: Date, recurringId: UUID?) -> String {
        let dateString = dateService.formatDate(date, style: .short)
        let idString = recurringId?.uuidString ?? "oneoff"
        return "\(dateString)-\(idString)"
    }
}
