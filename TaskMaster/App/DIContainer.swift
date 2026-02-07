import Foundation
import Combine

/// Dependency Injection Container
/// Manages app-wide dependencies and provides centralized access to use cases and repositories
final class DIContainer: ObservableObject {
    static let shared = DIContainer()

    // MARK: - Data Layer
    private lazy var persistenceController: PersistenceController = {
        PersistenceController.shared
    }()

    private lazy var taskDataSource: TaskDataSource = {
        CoreDataTaskDataSource(persistenceController: persistenceController)
    }()

    private lazy var taskRepository: TaskRepository = {
        TaskRepositoryImpl(dataSource: taskDataSource)
    }()

    // MARK: - Use Cases
    lazy var fetchTasksUseCase: FetchTasksUseCase = {
        FetchTasksUseCase(repository: taskRepository)
    }()

    lazy var createTaskUseCase: CreateTaskUseCase = {
        CreateTaskUseCase(repository: taskRepository)
    }()

    lazy var updateTaskUseCase: UpdateTaskUseCase = {
        UpdateTaskUseCase(repository: taskRepository)
    }()

    lazy var deleteTaskUseCase: DeleteTaskUseCase = {
        DeleteTaskUseCase(repository: taskRepository)
    }()

    lazy var toggleTaskStatusUseCase: ToggleTaskStatusUseCase = {
        ToggleTaskStatusUseCase(repository: taskRepository)
    }()

    lazy var fetchTaskStatisticsUseCase: FetchTaskStatisticsUseCase = {
        FetchTaskStatisticsUseCase(repository: taskRepository)
    }()

    private init() {}
}
