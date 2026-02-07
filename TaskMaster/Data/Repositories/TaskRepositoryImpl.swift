import Foundation
import Combine

/// Concrete implementation of TaskRepository
/// Acts as a bridge between the domain and data layers
final class TaskRepositoryImpl: TaskRepository {
    private let dataSource: TaskDataSource

    init(dataSource: TaskDataSource) {
        self.dataSource = dataSource
    }

    func fetchTasks() -> AnyPublisher<[Task], Error> {
        dataSource.fetchAll()
    }

    func fetchTask(by id: UUID) -> AnyPublisher<Task?, Error> {
        dataSource.fetch(by: id)
    }

    func createTask(_ task: Task) -> AnyPublisher<Task, Error> {
        dataSource.create(task)
    }

    func updateTask(_ task: Task) -> AnyPublisher<Task, Error> {
        dataSource.update(task)
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
        dataSource.delete(id: id)
    }

    func deleteTasks(ids: [UUID]) -> AnyPublisher<Void, Error> {
        dataSource.delete(ids: ids)
    }

    func fetchTasks(byStatus status: TaskStatus) -> AnyPublisher<[Task], Error> {
        dataSource.fetchAll()
            .map { tasks in
                tasks.filter { $0.status == status }
            }
            .eraseToAnyPublisher()
    }

    func fetchTasks(byCategory category: TaskCategory) -> AnyPublisher<[Task], Error> {
        dataSource.fetchAll()
            .map { tasks in
                tasks.filter { $0.category == category }
            }
            .eraseToAnyPublisher()
    }

    func fetchOverdueTasks() -> AnyPublisher<[Task], Error> {
        dataSource.fetchAll()
            .map { tasks in
                tasks.filter { $0.isOverdue }
            }
            .eraseToAnyPublisher()
    }
}
