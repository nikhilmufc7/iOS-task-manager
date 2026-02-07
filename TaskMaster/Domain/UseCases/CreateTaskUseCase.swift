import Foundation
import Combine

/// Use case for creating a new task
final class CreateTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(_ task: Task) -> AnyPublisher<Task, Error> {
        guard !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: TaskError.invalidTitle).eraseToAnyPublisher()
        }

        var taskToCreate = task
        taskToCreate.updatedAt = Date()

        return repository.createTask(taskToCreate)
    }
}

enum TaskError: LocalizedError {
    case invalidTitle
    case taskNotFound
    case persistenceError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "Task title cannot be empty"
        case .taskNotFound:
            return "Task not found"
        case .persistenceError(let error):
            return "Failed to save task: \(error.localizedDescription)"
        }
    }
}
