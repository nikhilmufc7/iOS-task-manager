import Foundation
import Combine

/// Statistics about tasks
struct TaskStatistics {
    let totalTasks: Int
    let completedTasks: Int
    let activeTasks: Int
    let overdueTasks: Int
    let tasksByCategory: [TaskCategory: Int]
    let tasksByPriority: [TaskPriority: Int]

    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

final class FetchTaskStatisticsUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<TaskStatistics, Error> {
        repository.fetchTasks()
            .map { tasks in
                let completed = tasks.filter { $0.status == .completed }
                let active = tasks.filter { $0.status != .completed }
                let overdue = tasks.filter { $0.isOverdue }

                let byCategory = Dictionary(grouping: tasks) { $0.category }
                    .mapValues { $0.count }

                let byPriority = Dictionary(grouping: tasks) { $0.priority }
                    .mapValues { $0.count }

                return TaskStatistics(
                    totalTasks: tasks.count,
                    completedTasks: completed.count,
                    activeTasks: active.count,
                    overdueTasks: overdue.count,
                    tasksByCategory: byCategory,
                    tasksByPriority: byPriority
                )
            }
            .eraseToAnyPublisher()
    }
}
