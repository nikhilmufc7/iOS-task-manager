import Foundation
import Combine

final class ToggleTaskStatusUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(_ task: Task) -> AnyPublisher<Task, Error> {
        var updatedTask = task

        switch task.status {
        case .completed:
            updatedTask.status = .inProgress
        case .todo, .inProgress:
            updatedTask.status = .completed
        }

        updatedTask.updatedAt = Date()

        return repository.updateTask(updatedTask)
    }
}
