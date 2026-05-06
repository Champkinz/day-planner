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
            // Date label
            HStack(spacing: 12) {
                Text(dateLabel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.6))

                if !dateService.isToday(selectedDate) {
                    Button("Back to Today") {
                        selectedDate = Date()
                    }
                    .font(.system(size: 11, weight: .medium))
                    .buttonStyle(.plain)
                    .foregroundColor(AppTheme.accent)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

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
        .background(
            ZStack {
                AppTheme.appBackground
                LinearGradient(
                    colors: [
                        AppTheme.accent.opacity(0.06),
                        AppTheme.statusDone.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ViewModeToggleButton(viewMode: $viewModel.viewMode)
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddTodo = true
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add Todo")
            }

            ToolbarItem(placement: .primaryAction) {
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
                }
                .menuIndicator(.hidden)
            }
        }
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

    private var statsBar: some View {
        HStack(spacing: 10) {
            let todosForDay = viewModel.todos(for: selectedDate)
            let doneCount = todosForDay.filter { $0.status == .done }.count
            let doingCount = todosForDay.filter { $0.status == .doing }.count
            let totalCount = todosForDay.count

            if totalCount > 0 {
                HStack(spacing: 5) {
                    Circle()
                        .fill(AppTheme.statusDone)
                        .frame(width: 6, height: 6)
                    Text("\(doneCount)/\(totalCount)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.primary.opacity(0.6))
                }

                if doingCount > 0 {
                    Text("·")
                        .foregroundColor(.primary.opacity(0.25))
                    HStack(spacing: 5) {
                        Circle()
                            .fill(AppTheme.statusDoing)
                            .frame(width: 6, height: 6)
                        Text("\(doingCount) in progress")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(AppTheme.statusDoing.opacity(0.85))
                    }
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
