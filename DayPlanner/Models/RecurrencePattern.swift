//
//  RecurrencePattern.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

enum RecurrenceType: String, Codable {
    case daily
    case weekly
    case monthly
    case custom
}

struct RecurrencePattern: Codable, Identifiable, Equatable {
    let id: UUID
    let type: RecurrenceType
    let interval: Int // e.g., every 2 days
    let daysOfWeek: Set<Int>? // 1-7 for weekly (1 = Sunday, 7 = Saturday)
    let dayOfMonth: Int? // 1-31 for monthly

    init(
        id: UUID = UUID(),
        type: RecurrenceType,
        interval: Int = 1,
        daysOfWeek: Set<Int>? = nil,
        dayOfMonth: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.interval = interval
        self.daysOfWeek = daysOfWeek
        self.dayOfMonth = dayOfMonth
    }

    // Convenience initializers for common patterns
    static func daily(interval: Int = 1) -> RecurrencePattern {
        RecurrencePattern(type: .daily, interval: interval)
    }

    static func weekly(daysOfWeek: Set<Int>, interval: Int = 1) -> RecurrencePattern {
        RecurrencePattern(type: .weekly, interval: interval, daysOfWeek: daysOfWeek)
    }

    static func monthly(dayOfMonth: Int, interval: Int = 1) -> RecurrencePattern {
        RecurrencePattern(type: .monthly, interval: interval, dayOfMonth: dayOfMonth)
    }
}
