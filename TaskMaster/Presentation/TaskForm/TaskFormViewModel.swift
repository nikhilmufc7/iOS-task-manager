import Foundation
import Combine

/// View model for task creation and editing
final class TaskFormViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var title = ""
    @Published var description = ""
    @Published var status: TaskStatus = .todo
    @Published var priority: TaskPriority = .medium
    @Published var category: TaskCategory = .personal
    @Published var hasDueDate = false
    @Published var dueDate = Date()
    @Published var isSaving = false
    @Published var error: Error?
    @Published var didSave = false
    @Published var savedTask: Task?

    let mode: TaskFormView.Mode

    private let createTaskUseCase: CreateTaskUseCase
    private let updateTaskUseCase: UpdateTaskUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        mode: TaskFormView.Mode,
        createTaskUseCase: CreateTaskUseCase,
        updateTaskUseCase: UpdateTaskUseCase
    ) {
        self.mode = mode
        self.createTaskUseCase = createTaskUseCase
        self.updateTaskUseCase = updateTaskUseCase

        if case .edit(let task) = mode {
            loadTask(task)
        }
    }

    // MARK: - Computed Properties
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions
    func save() {
        guard isValid else { return }

        isSaving = true
        error = nil

        let task = buildTask()

        let publisher: AnyPublisher<Task, Error>
        switch mode {
        case .create:
            publisher = createTaskUseCase.execute(task)
        case .edit:
            publisher = updateTaskUseCase.execute(task)
        }

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSaving = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] task in
                    self?.savedTask = task
                    self?.didSave = true
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Private Helpers
    private func loadTask(_ task: Task) {
        self.title = task.title
        self.description = task.description
        self.status = task.status
        self.priority = task.priority
        self.category = task.category
        self.hasDueDate = task.dueDate != nil
        self.dueDate = task.dueDate ?? Date()
    }

    private func buildTask() -> Task {
        let taskId: UUID
        let createdAt: Date

        if case .edit(let existingTask) = mode {
            taskId = existingTask.id
            createdAt = existingTask.createdAt
        } else {
            taskId = UUID()
            createdAt = Date()
        }

        return Task(
            id: taskId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            priority: priority,
            category: category,
            dueDate: hasDueDate ? dueDate : nil,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
