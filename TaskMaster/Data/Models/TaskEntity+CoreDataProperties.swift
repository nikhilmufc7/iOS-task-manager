import Foundation
import CoreData

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String
    @NSManaged public var status: String
    @NSManaged public var priority: String
    @NSManaged public var category: String
    @NSManaged public var dueDate: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

}

extension TaskEntity : Identifiable {

}

// MARK: - Mapping Extensions

extension TaskEntity {
    /// Converts the Core Data entity to a domain Task model
    func toDomainModel() -> Task {
        Task(
            id: id,
            title: title,
            description: taskDescription,
            status: TaskStatus(rawValue: status) ?? .todo,
            priority: TaskPriority(rawValue: priority) ?? .medium,
            category: TaskCategory(rawValue: category) ?? .personal,
            dueDate: dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Updates the entity with values from a domain Task model
    func update(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.taskDescription = task.description
        self.status = task.status.rawValue
        self.priority = task.priority.rawValue
        self.category = task.category.rawValue
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
    }
}
