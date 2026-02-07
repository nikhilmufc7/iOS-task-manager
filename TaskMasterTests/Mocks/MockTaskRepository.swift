import Foundation
import Combine
@testable import TaskMaster

/// Mock repository for testing use cases and view models
final class MockTaskRepository: TaskRepository {
    var tasks: [Task] = []
    var shouldFail = false
    var error: Error?

    func fetchTasks() -> AnyPublisher<[Task], Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.fetchFailed)
                .eraseToAnyPublisher()
        }
        return Just(tasks)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchTask(by id: UUID) -> AnyPublisher<Task?, Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.fetchFailed)
                .eraseToAnyPublisher()
        }
        let task = tasks.first { $0.id == id }
        return Just(task)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func createTask(_ task: Task) -> AnyPublisher<Task, Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.createFailed)
                .eraseToAnyPublisher()
        }
        tasks.append(task)
        return Just(task)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateTask(_ task: Task) -> AnyPublisher<Task, Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.updateFailed)
                .eraseToAnyPublisher()
        }
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            return Just(task)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: MockError.notFound)
            .eraseToAnyPublisher()
    }

    func deleteTask(id: UUID) -> AnyPublisher<Void, Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.deleteFailed)
                .eraseToAnyPublisher()
        }
        tasks.removeAll { $0.id == id }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func deleteTasks(ids: [UUID]) -> AnyPublisher<Void, Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.deleteFailed)
                .eraseToAnyPublisher()
        }
        tasks.removeAll { ids.contains($0.id) }
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchTasks(byStatus status: TaskStatus) -> AnyPublisher<[Task], Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.fetchFailed)
                .eraseToAnyPublisher()
        }
        let filtered = tasks.filter { $0.status == status }
        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchTasks(byCategory category: TaskCategory) -> AnyPublisher<[Task], Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.fetchFailed)
                .eraseToAnyPublisher()
        }
        let filtered = tasks.filter { $0.category == category }
        return Just(filtered)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchOverdueTasks() -> AnyPublisher<[Task], Error> {
        if shouldFail {
            return Fail(error: error ?? MockError.fetchFailed)
                .eraseToAnyPublisher()
        }
        let overdue = tasks.filter { $0.isOverdue }
        return Just(overdue)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

enum MockError: LocalizedError {
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .fetchFailed: return "Fetch failed"
        case .createFailed: return "Create failed"
        case .updateFailed: return "Update failed"
        case .deleteFailed: return "Delete failed"
        case .notFound: return "Not found"
        }
    }
}
