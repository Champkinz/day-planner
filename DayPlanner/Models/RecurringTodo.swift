//
//  RecurringTodo.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

struct RecurringTodo: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var isMandatory: Bool
    var recurrencePattern: RecurrencePattern
    var startDate: Date
    var endDate: Date?
    var createdAt: Date
    var isActive: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        isMandatory: Bool,
        recurrencePattern: RecurrencePattern,
        startDate: Date,
        endDate: Date? = nil,
        createdAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isMandatory = isMandatory
        self.recurrencePattern = recurrencePattern
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
        self.isActive = isActive
    }
}
