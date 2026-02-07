import Foundation
import Combine

/// View model for task detail view
final class TaskDetailViewModel: ObservableObject {
    @Published var task: Task
    @Published var showingEditSheet = false
    @Published var showingDeleteAlert = false
    @Published var didDelete = false

    private let updateTaskUseCase: UpdateTaskUseCase
    private let deleteTaskUseCase: DeleteTaskUseCase
    private let toggleTaskStatusUseCase: ToggleTaskStatusUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        task: Task,
        updateTaskUseCase: UpdateTaskUseCase,
        deleteTaskUseCase: DeleteTaskUseCase,
        toggleTaskStatusUseCase: ToggleTaskStatusUseCase
    ) {
        self.task = task
        self.updateTaskUseCase = updateTaskUseCase
        self.deleteTaskUseCase = deleteTaskUseCase
        self.toggleTaskStatusUseCase = toggleTaskStatusUseCase
    }

    func toggleStatus() {
        toggleTaskStatusUseCase.execute(task)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] updatedTask in
                    self?.task = updatedTask
                }
            )
            .store(in: &cancellables)
    }

    func deleteTask() {
        deleteTaskUseCase.execute(id: task.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .finished = completion {
                        self?.didDelete = true
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
