//
//  DateService.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import Foundation

class DateService {
    static let shared = DateService()
    private let calendar = Calendar.current

    private init() {}

    // MARK: - Date Manipulation

    func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func addDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    // MARK: - Date Comparison

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    func daysBetween(_ start: Date, _ end: Date) -> Int {
        let components = calendar.dateComponents([.day], from: startOfDay(start), to: startOfDay(end))
        return components.day ?? 0
    }

    // MARK: - Date Components

    func weekday(of date: Date) -> Int {
        // Returns 1 for Sunday, 2 for Monday, ..., 7 for Saturday
        calendar.component(.weekday, from: date)
    }

    func dayOfMonth(of date: Date) -> Int {
        calendar.component(.day, from: date)
    }

    // MARK: - Date Range

    func dateRange(from start: Date, to end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startOfDay(start)
        let endDate = startOfDay(end)

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = addDays(1, to: currentDate)
        }

        return dates
    }

    // MARK: - Formatting

    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatRelativeDate(_ date: Date) -> String {
        if isToday(date) {
            return "Today"
        }

        let tomorrow = addDays(1, to: Date())
        if isSameDay(date, tomorrow) {
            return "Tomorrow"
        }

        let yesterday = addDays(-1, to: Date())
        if isSameDay(date, yesterday) {
            return "Yesterday"
        }

        return formatDate(date)
    }
}
