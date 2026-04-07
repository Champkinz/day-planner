import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject var viewModel: TodoListViewModel
    @State private var selectedDate = Date()
    @State private var showingAddTodo = false
    @State private var showingRecurringTodos = false
    @State private var showingCalendar = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    private let dateService = DateService.shared

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.bar)

            Divider()

            // Date label
            HStack {
                Text(dateLabel)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)

                if !dateService.isToday(selectedDate) {
                    Button("Back to Today") {
                        selectedDate = Date()
                    }
                    .font(.system(size: 11))
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            // Content view
            Group {
                switch viewModel.viewMode {
                case .list:
                    ListView(selectedDate: selectedDate)
                case .kanban:
                    KanbanView(selectedDate: selectedDate)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            statsBar
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
        }
        .background(.ultraThinMaterial)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .sheet(isPresented: $showingAddTodo) {
            AddTodoView(date: selectedDate)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingRecurringTodos) {
            RecurringTodoListView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingCalendar) {
            BeautifulCalendarView(selectedDate: $selectedDate)
        }
    }

    private var topBar: some View {
        HStack {
            Picker("View", selection: $viewModel.viewMode) {
                Text("List").tag(ViewMode.list)
                Text("Kanban").tag(ViewMode.kanban)
            }
            .pickerStyle(.segmented)
            .frame(width: 160)

            Spacer()

            Button {
                showingAddTodo = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .help("Add Todo")

            Menu {
                Button {
                    showingCalendar = true
                } label: {
                    Label("Pick Date", systemImage: "calendar")
                }

                Button {
                    showingRecurringTodos = true
                } label: {
                    Label("Recurring Todos", systemImage: "repeat.circle")
                }

                Divider()

                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: isDarkMode ? "sun.max.fill" : "moon.fill")
                }

                Divider()

                SettingsLink {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(width: 26, height: 26)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
        }
    }

    private var statsBar: some View {
        HStack {
            let todosForDay = viewModel.todos(for: selectedDate)
            let doneCount = todosForDay.filter { $0.status == .done }.count
            let doingCount = todosForDay.filter { $0.status == .doing }.count
            let totalCount = todosForDay.count

            if totalCount > 0 {
                Text("\(doneCount)/\(totalCount) done")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                if doingCount > 0 {
                    Text("·")
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("\(doingCount) in progress")
                        .font(.system(size: 11))
                        .foregroundColor(.orange.opacity(0.7))
                }
            }

            Spacer()
        }
    }

    private var dateLabel: String {
        let relative = dateService.formatRelativeDate(selectedDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let short = formatter.string(from: selectedDate)
        if relative == short {
            return relative
        }
        return "\(relative) · \(short)"
    }
}

#Preview {
    MainWindowView()
        .environmentObject(TodoListViewModel.shared)
        .frame(width: 800, height: 550)
}
