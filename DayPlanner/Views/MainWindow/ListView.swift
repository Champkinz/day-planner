import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    let selectedDate: Date

    var body: some View {
        let todosForDay = viewModel.todos(for: selectedDate)

        if todosForDay.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 6) {
                    ForEach(todosForDay) { todo in
                        GlassTodoRow(todo: todo, selectedDate: selectedDate)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.4))

            Text("No todos for this day")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
