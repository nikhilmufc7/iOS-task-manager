import Foundation
import CoreData
import Combine

/// Protocol defining data source operations for tasks
protocol TaskDataSource {
    func fetchAll() -> AnyPublisher<[Task], Error>
    func fetch(by id: UUID) -> AnyPublisher<Task?, Error>
    func create(_ task: Task) -> AnyPublisher<Task, Error>
    func update(_ task: Task) -> AnyPublisher<Task, Error>
    func delete(id: UUID) -> AnyPublisher<Void, Error>
    func delete(ids: [UUID]) -> AnyPublisher<Void, Error>
}

/// Core Data implementation of TaskDataSource
final class CoreDataTaskDataSource: TaskDataSource {
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.context = persistenceController.container.viewContext
    }

    func fetchAll() -> AnyPublisher<[Task], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let request = TaskEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: false)]

            do {
                let entities = try self.context.fetch(request)
                let tasks = entities.map { $0.toDomainModel() }
                promise(.success(tasks))
            } catch {
                promise(.failure(DataSourceError.fetchFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetch(by id: UUID) -> AnyPublisher<Task?, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            do {
                let entities = try self.context.fetch(request)
                let task = entities.first?.toDomainModel()
                promise(.success(task))
            } catch {
                promise(.failure(DataSourceError.fetchFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func create(_ task: Task) -> AnyPublisher<Task, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let entity = TaskEntity(context: self.context)
            entity.update(from: task)

            do {
                try self.context.save()
                promise(.success(entity.toDomainModel()))
            } catch {
                promise(.failure(DataSourceError.saveFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func update(_ task: Task) -> AnyPublisher<Task, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
            request.fetchLimit = 1

            do {
                guard let entity = try self.context.fetch(request).first else {
                    promise(.failure(DataSourceError.notFound))
                    return
                }

                entity.update(from: task)
                try self.context.save()
                promise(.success(entity.toDomainModel()))
            } catch {
                promise(.failure(DataSourceError.saveFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(id: UUID) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            do {
                guard let entity = try self.context.fetch(request).first else {
                    promise(.failure(DataSourceError.notFound))
                    return
                }

                self.context.delete(entity)
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(DataSourceError.deleteFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(ids: [UUID]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(DataSourceError.contextUnavailable))
                return
            }

            let request = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", ids)

            do {
                let entities = try self.context.fetch(request)
                entities.forEach { self.context.delete($0) }
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(DataSourceError.deleteFailed(error)))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Data Source Errors

enum DataSourceError: LocalizedError {
    case contextUnavailable
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case notFound

    var errorDescription: String? {
        switch self {
        case .contextUnavailable:
            return "Database context is unavailable"
        case .fetchFailed(let error):
            return "Failed to fetch data: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \(error.localizedDescription)"
        case .notFound:
            return "Item not found"
        }
    }
}
