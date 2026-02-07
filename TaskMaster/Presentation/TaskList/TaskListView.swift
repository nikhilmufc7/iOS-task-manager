import SwiftUI

/// Main task list view displaying all tasks with filtering and sorting options
struct TaskListView: View {
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel: TaskListViewModel
    @State private var showingStats = false

    init() {
        // ViewModel will be injected via environment
        _viewModel = StateObject(wrappedValue: TaskListViewModel(
            fetchTasksUseCase: DIContainer.shared.fetchTasksUseCase,
            createTaskUseCase: DIContainer.shared.createTaskUseCase,
            updateTaskUseCase: DIContainer.shared.updateTaskUseCase,
            deleteTaskUseCase: DIContainer.shared.deleteTaskUseCase,
            toggleTaskStatusUseCase: DIContainer.shared.toggleTaskStatusUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    LoadingView(message: "Loading tasks...")
                } else if let error = viewModel.error, viewModel.tasks.isEmpty {
                    ErrorView(error: error) {
                        viewModel.loadTasks()
                    }
                } else if viewModel.filteredTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        filterMenu
                        sortMenu
                        Divider()
                        Button {
                            showingStats = true
                        } label: {
                            Label("Statistics", systemImage: "chart.bar")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add new task")
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .refreshable {
                viewModel.loadTasks()
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                TaskFormView(mode: .create) { task in
                    viewModel.loadTasks()
                }
            }
            .sheet(item: $viewModel.selectedTask) { task in
                TaskDetailView(task: task) {
                    viewModel.loadTasks()
                }
            }
            .sheet(isPresented: $showingStats) {
                StatisticsView()
            }
            .onAppear {
                viewModel.loadTasks()
            }
        }
    }

    // MARK: - Subviews
    private var taskList: some View {
        List {
            Section {
                ForEach(viewModel.filteredTasks) { task in
                    Button {
                        viewModel.selectedTask = task
                    } label: {
                        TaskRowView(task: task) {
                            viewModel.toggleTaskStatus(task)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteTask(task)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteTasks(at: indexSet)
                }
            } header: {
                if !viewModel.searchText.isEmpty {
                    Text("\(viewModel.filteredTasks.count) result(s)")
                }
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: viewModel.searchText.isEmpty ? "checkmark.circle" : "magnifyingglass",
            title: viewModel.searchText.isEmpty ? "No Tasks" : "No Results",
            message: viewModel.searchText.isEmpty
                ? "Create your first task to get started"
                : "Try adjusting your search or filters",
            actionTitle: viewModel.searchText.isEmpty ? "Create Task" : nil,
            action: viewModel.searchText.isEmpty ? {
                viewModel.showingAddSheet = true
            } : nil
        )
    }

    private var filterMenu: some View {
        Menu {
            ForEach(TaskFilter.allCases) { filter in
                Button {
                    viewModel.selectedFilter = filter
                } label: {
                    Label(
                        filter.displayName,
                        systemImage: viewModel.selectedFilter == filter ? "checkmark" : ""
                    )
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(TaskSortOption.allCases) { option in
                Button {
                    if viewModel.selectedSortOption == option {
                        viewModel.sortAscending.toggle()
                    } else {
                        viewModel.selectedSortOption = option
                        viewModel.sortAscending = false
                    }
                } label: {
                    HStack {
                        Text(option.displayName)
                        if viewModel.selectedSortOption == option {
                            Image(systemName: viewModel.sortAscending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
}

#Preview {
    TaskListView()
        .environmentObject(DIContainer.shared)
}
