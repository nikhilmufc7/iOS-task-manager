import Foundation
import Combine

protocol TaskRepository {

    func fetchTasks() -> AnyPublisher<[Task], Error>

    func fetchTask(by id: UUID) -> AnyPublisher<Task?, Error>

    func createTask(_ task: Task) -> AnyPublisher<Task, Error>

    func updateTask(_ task: Task) -> AnyPublisher<Task, Error>

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error>

    func deleteTasks(ids: [UUID]) -> AnyPublisher<Void, Error>

    func fetchTasks(byStatus status: TaskStatus) -> AnyPublisher<[Task], Error>

    func fetchTasks(byCategory category: TaskCategory) -> AnyPublisher<[Task], Error>

    func fetchOverdueTasks() -> AnyPublisher<[Task], Error>
}
