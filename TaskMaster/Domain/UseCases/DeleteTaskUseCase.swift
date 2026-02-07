import Foundation
import Combine

/// Use case for deleting tasks
final class DeleteTaskUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(id: UUID) -> AnyPublisher<Void, Error> {
        repository.deleteTask(id: id)
    }

    func execute(ids: [UUID]) -> AnyPublisher<Void, Error> {
        repository.deleteTasks(ids: ids)
    }
}
