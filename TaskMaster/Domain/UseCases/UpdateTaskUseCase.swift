import Foundation
import Combine

final class UpdateTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(_ task: Task) -> AnyPublisher<Task, Error> {
        guard !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: TaskError.invalidTitle).eraseToAnyPublisher()
        }

        var updatedTask = task
        updatedTask.updatedAt = Date()

        return repository.updateTask(updatedTask)
    }
}
