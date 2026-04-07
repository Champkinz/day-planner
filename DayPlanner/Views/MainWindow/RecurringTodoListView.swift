//
//  RecurringTodoListView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI

struct RecurringTodoListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddRecurring = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Manage Recurring Todos")
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

            Divider()

            // List
            if viewModel.recurringTodos.isEmpty {
                ContentUnavailableView(
                    "No Recurring Todos",
                    systemImage: "repeat.circle",
                    description: Text("Add a recurring todo to get started")
                )
            } else {
                List {
                    ForEach(viewModel.recurringTodos) { recurring in
                        RecurringTodoRow(recurring: recurring)
                    }
                }
                .listStyle(.inset)
            }

            Divider()

            // Action Buttons
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(action: { showingAddRecurring = true }) {
                    Label("Add Recurring Todo", systemImage: "plus.circle.fill")
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 700, height: 500)
        .sheet(isPresented: $showingAddRecurring) {
            AddRecurringTodoView()
                .environmentObject(viewModel)
        }
    }
}

struct RecurringTodoRow: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    let recurring: RecurringTodo

    var recurrenceDescription: String {
        switch recurring.recurrencePattern.type {
        case .daily:
            let interval = recurring.recurrencePattern.interval
            return interval == 1 ? "Every day" : "Every \(interval) days"
        case .weekly:
            if let days = recurring.recurrencePattern.daysOfWeek {
                let dayNames = days.sorted().map { dayNumber in
                    let formatter = DateFormatter()
                    return formatter.shortWeekdaySymbols[dayNumber - 1]
                }
                return "Weekly on " + dayNames.joined(separator: ", ")
            }
            return "Weekly"
        case .monthly:
            if let day = recurring.recurrencePattern.dayOfMonth {
                return "Monthly on day \(day)"
            }
            return "Monthly"
        case .custom:
            return "Custom pattern"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recurring.title)
                    .font(.headline)

                Text(recurrenceDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let description = recurring.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            HStack(spacing: 12) {
                if recurring.isMandatory {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .help("Mandatory")
                }

                Toggle("Active", isOn: Binding(
                    get: { recurring.isActive },
                    set: { _ in viewModel.toggleRecurringTodoActive(recurring) }
                ))
                .toggleStyle(.switch)
                .help(recurring.isActive ? "Active" : "Inactive")
            }
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button("Delete") {
                viewModel.deleteRecurringTodo(recurring)
            }
        }
    }
}

struct AddRecurringTodoView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isMandatory: Bool = false
    @State private var recurrenceType: RecurrenceType = .daily
    @State private var interval: Int = 1
    @State private var selectedDaysOfWeek: Set<Int> = []
    @State private var dayOfMonth: Int = 1
    @State private var startDate: Date = Date()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Recurring Todo")
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

            Divider()

            // Form
            ScrollView {
                Form {
                    Section("Basic Information") {
                        TextField("Todo title", text: $title)
                            .textFieldStyle(.roundedBorder)

                        TextField("Description (optional)", text: $description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)

                        Toggle("Mandatory", isOn: $isMandatory)
                    }

                    Section("Recurrence Pattern") {
                        Picker("Pattern", selection: $recurrenceType) {
                            Text("Daily").tag(RecurrenceType.daily)
                            Text("Weekly").tag(RecurrenceType.weekly)
                            Text("Monthly").tag(RecurrenceType.monthly)
                        }
                        .pickerStyle(.segmented)

                        switch recurrenceType {
                        case .daily:
                            Stepper("Every \(interval) day(s)", value: $interval, in: 1...30)
                        case .weekly:
                            DaysOfWeekPicker(selectedDays: $selectedDaysOfWeek)
                        case .monthly:
                            Stepper("Day \(dayOfMonth) of each month", value: $dayOfMonth, in: 1...31)
                        case .custom:
                            Text("Custom patterns not yet supported")
                                .foregroundColor(.secondary)
                        }

                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
            }

            Divider()

            // Action Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Add Recurring Todo") {
                    addRecurringTodo()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 600, height: 550)
    }

    private var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return false }

        if recurrenceType == .weekly {
            return !selectedDaysOfWeek.isEmpty
        }

        return true
    }

    private func addRecurringTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        let pattern: RecurrencePattern
        switch recurrenceType {
        case .daily:
            pattern = .daily(interval: interval)
        case .weekly:
            guard !selectedDaysOfWeek.isEmpty else { return }
            pattern = .weekly(daysOfWeek: selectedDaysOfWeek, interval: 1)
        case .monthly:
            pattern = .monthly(dayOfMonth: dayOfMonth, interval: 1)
        case .custom:
            pattern = .daily(interval: interval) // Fallback
        }

        let recurring = RecurringTodo(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            isMandatory: isMandatory,
            recurrencePattern: pattern,
            startDate: startDate
        )

        viewModel.addRecurringTodo(recurring)
        dismiss()
    }
}

struct DaysOfWeekPicker: View {
    @Binding var selectedDays: Set<Int>

    private let weekdays = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select days of week:")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                ForEach(weekdays, id: \.0) { day, name in
                    Toggle(name, isOn: Binding(
                        get: { selectedDays.contains(day) },
                        set: { isSelected in
                            if isSelected {
                                selectedDays.insert(day)
                            } else {
                                selectedDays.remove(day)
                            }
                        }
                    ))
                    .toggleStyle(.button)
                }
            }
        }
    }
}

#Preview {
    RecurringTodoListView()
        .environmentObject(TodoListViewModel.shared)
}
