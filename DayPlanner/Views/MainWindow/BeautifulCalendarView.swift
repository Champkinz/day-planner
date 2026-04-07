//
//  BeautifulCalendarView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI

struct BeautifulCalendarView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Calendar
            VStack(spacing: 20) {
                // Month/Year selector
                monthYearSelector

                // Weekday headers
                weekdayHeaders
                    .padding(.top, 4)

                // Calendar grid
                calendarGrid

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            // Footer
            footer
        }
        .frame(width: 420, height: 550)
    }

    private var header: some View {
        HStack {
            Text("Select Date")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private var monthYearSelector: some View {
        HStack {
            // Previous month
            Button(action: previousMonth) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)

            Spacer()

            // Month and year
            Text(dateFormatter.string(from: currentMonth))
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            // Next month
            Button(action: nextMonth) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }

    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }

    private var calendarGrid: some View {
        let days = getDaysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth,
                        isToday: calendar.isDateInToday(date),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    )
                } else {
                    Color.clear
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button("Today") {
                selectedDate = Date()
                currentMonth = Date()
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.bordered)

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }

    // MARK: - Helper Functions

    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        var days: [Date?] = []

        calendar.enumerateDates(
            startingAfter: dateInterval.start,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date >= dateInterval.start && date < dateInterval.end {
                    days.append(date)
                } else {
                    stop = true
                }
            }
        }

        // Pad with nil for leading empty cells
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingDays = firstWeekday - 1
        days = Array(repeating: nil, count: leadingDays) + days

        return days
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentMonth = newMonth
            }
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentMonth = newMonth
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool

    private let calendar = Calendar.current

    var dayNumber: String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }

    var body: some View {
        Button(action: {
            selectedDate = date
            // If clicking a date from a different month, navigate to that month
            if !isCurrentMonth {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonth = date
                }
            }
        }) {
            ZStack {
                // Background
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor)
                } else if isToday {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.accentColor, lineWidth: 2)
                }

                // Day number
                Text(dayNumber)
                    .font(.system(size: 16, weight: isToday || isSelected ? .semibold : .regular))
                    .foregroundColor(
                        isSelected ? .white :
                        isToday ? .accentColor :
                        isCurrentMonth ? .primary : .secondary.opacity(0.3)
                    )
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .opacity(isCurrentMonth ? 1.0 : 0.5) // Make other month dates more transparent
    }
}

#Preview {
    BeautifulCalendarView(selectedDate: .constant(Date()))
}
