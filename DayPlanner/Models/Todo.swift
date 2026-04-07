//
//  Todo.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

enum TodoType: String, Codable {
    case recurring
    case oneOff
}

enum TodoStatus: String, Codable {
    case todo
    case doing
    case done
}

struct Todo: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String?
    var date: Date
    var status: TodoStatus
    var isMandatory: Bool
    var type: TodoType
    var recurringTodoId: UUID?
    var completedAt: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        date: Date,
        status: TodoStatus = .todo,
        isMandatory: Bool = false,
        type: TodoType,
        recurringTodoId: UUID? = nil,
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.isMandatory = isMandatory
        self.type = type
        self.recurringTodoId = recurringTodoId
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
}
