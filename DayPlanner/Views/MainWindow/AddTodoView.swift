//
//  AddTodoView.swift
//  DayPlanner
//
//  Created on 2026-01-01.
//

import SwiftUI

struct AddTodoView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @Environment(\.dismiss) private var dismiss

    let date: Date

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isMandatory: Bool = false
    @State private var selectedDate: Date

    init(date: Date = Date()) {
        self.date = date
        _selectedDate = State(initialValue: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Todo")
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
            Form {
                Section {
                    TextField("Todo title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }

                Section {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])

                    Toggle("Mandatory", isOn: $isMandatory)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

            Divider()

            // Action Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Add Todo") {
                    addTodo()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }

    private func addTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else { return }

        let todo = Todo(
            title: trimmedTitle,
            description: trimmedDescription.isEmpty ? nil : trimmedDescription,
            date: selectedDate,
            status: .todo,
            isMandatory: isMandatory,
            type: .oneOff
        )

        viewModel.addTodo(todo)
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .environmentObject(TodoListViewModel.shared)
}
