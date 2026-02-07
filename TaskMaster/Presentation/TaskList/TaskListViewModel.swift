import Foundation
import Combine

/// View model for the task list screen
/// Manages task list state and coordinates use cases
final class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedSortOption: TaskSortOption = .createdDate
    @Published var sortAscending = false
    @Published var showingAddSheet = false
    @Published var selectedTask: Task?

    private let fetchTasksUseCase: FetchTasksUseCase
    private let createTaskUseCase: CreateTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let toggleTaskStatusUseCase: ToggleTaskStatusUseCase

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        fetchTasksUseCase: FetchTasksUseCase,
        createTaskUseCase: CreateTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase,
        toggleTaskStatusUseCase: ToggleTaskStatusUseCase
    ) {
        self.fetchTasksUseCase = fetchTasksUseCase
        self.createTaskUseCase = createTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.toggleTaskStatusUseCase = toggleTaskStatusUseCase

        setupSearchObserver()
        setupFilterObserver()
        setupSortObserver()
    }

    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        }

        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            task.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var taskCountByStatus: (todo: Int, inProgress: Int, completed: Int) {
        let todo = tasks.filter { $0.status == .todo }.count
        let inProgress = tasks.filter { $0.status == .inProgress }.count
        let completed = tasks.filter { $0.status == .completed }.count
        return (todo, inProgress, completed)
    }

    func loadTasks() {
        isLoading = true
        error = nil

        fetchTasksUseCase.execute(
            filter: selectedFilter,
            sortOption: selectedSortOption,
            ascending: sortAscending
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            },
            receiveValue: { [weak self] tasks in
                self?.tasks = tasks
            }
        )
        .store(in: &cancellables)
    }

    func toggleTaskStatus(_ task: Task) {
        toggleTaskStatusUseCase.execute(task)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] updatedTask in
                    self?.updateTaskInList(updatedTask)
                }
            )
            .store(in: &cancellables)
    }

    func deleteTask(_ task: Task) {
        deleteTaskUseCase.execute(id: task.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    } else {
                        self?.removeTaskFromList(task.id)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { filteredTasks[$0] }
        let ids = tasksToDelete.map { $0.id }

        deleteTaskUseCase.execute(ids: ids)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.error = error
                    } else {
                        ids.forEach { self?.removeTaskFromList($0) }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Helpers
    private func updateTaskInList(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    private func removeTaskFromList(_ id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                // Search is handled through filteredTasks computed property
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func setupFilterObserver() {
        $selectedFilter
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadTasks()
            }
            .store(in: &cancellables)
    }

    private func setupSortObserver() {
        Publishers.CombineLatest($selectedSortOption, $sortAscending)
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadTasks()
            }
            .store(in: &cancellables)
    }
}
