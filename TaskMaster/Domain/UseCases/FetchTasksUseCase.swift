import Foundation
import Combine

/// Use case for fetching tasks with iltering and sorting
final class FetchTasksUseCase {
    private let repository: TaskRepository

    init(repository: TaskRepository) {
        self.repository = repository
    }

    func execute(
        filter: TaskFilter = .all,
        sortOption: TaskSortOption = .createdDate,
        ascending: Bool = false
    ) -> AnyPublisher<[Task], Error> {
        repository.fetchTasks()
            .map { [weak self] tasks in
                guard let self = self else { return tasks }
                let filteredTasks = self.applyFilter(filter, to: tasks)
                return self.sort(filteredTasks, by: sortOption, ascending: ascending)
            }
            .eraseToAnyPublisher()
    }

    func execute(forCategory category: TaskCategory) -> AnyPublisher<[Task], Error> {
        repository.fetchTasks(byCategory: category)
    }

    private func applyFilter(_ filter: TaskFilter, to tasks: [Task]) -> [Task] {
        switch filter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { $0.status != .completed }
        case .completed:
            return tasks.filter { $0.status == .completed }
        case .overdue:
            return tasks.filter { $0.isOverdue }
        }
    }

    private func sort(_ tasks: [Task], by option: TaskSortOption, ascending: Bool) -> [Task] {
        let sorted: [Task]

        switch option {
        case .createdDate:
            sorted = tasks.sorted { $0.createdAt < $1.createdAt }
        case .dueDate:
            sorted = tasks.sorted { task1, task2 in
                guard let date1 = task1.dueDate else { return false }
                guard let date2 = task2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            sorted = tasks.sorted { $0.priority > $1.priority }
        case .title:
            sorted = tasks.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return ascending ? sorted : sorted.reversed()
    }
}
