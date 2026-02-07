import Foundation

/// Task entity representing a to-do item
/// This is a pure domain model with no dependencies on frameworks
struct Task: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var status: TaskStatus
    var priority: TaskPriority
    var category: TaskCategory
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        status: TaskStatus = .todo,
        priority: TaskPriority = .medium,
        category: TaskCategory = .personal,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.category = category
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Returns true if the task is overdue
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != .completed
    }

    /// Returns true if the task is due today
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    /// Returns true if the task is due within the next 7 days
    var isDueSoon: Bool {
        guard let dueDate = dueDate else { return false }
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        return dueDate <= weekFromNow && dueDate >= Date()
    }
}

// MARK: - Task Status

enum TaskStatus: String, Codable, CaseIterable, Identifiable {
    case todo
    case inProgress
    case completed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var iconName: String {
        switch self {
        case .todo: return "circle"
        case .inProgress: return "circle.lefthalf.filled"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Task Priority

enum TaskPriority: String, Codable, CaseIterable, Identifiable, Comparable {
    case low
    case medium
    case high
    case urgent

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "equal.circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.circle.fill"
        }
    }

    var sortOrder: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        case .urgent: return 3
        }
    }

    static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

// MARK: - Task Category

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case personal
    case work
    case shopping
    case health
    case finance
    case home

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var iconName: String {
        switch self {
        case .personal: return "person.fill"
        case .work: return "briefcase.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .home: return "house.fill"
        }
    }

    var colorName: String {
        switch self {
        case .personal: return "CategoryPersonal"
        case .work: return "CategoryWork"
        case .shopping: return "CategoryShopping"
        case .health: return "CategoryHealth"
        case .finance: return "CategoryFinance"
        case .home: return "CategoryHome"
        }
    }
}

// MARK: - Task Filter

enum TaskFilter: String, CaseIterable, Identifiable {
    case all
    case active
    case completed
    case overdue

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .completed: return "Completed"
        case .overdue: return "Overdue"
        }
    }
}

// MARK: - Task Sort Option

enum TaskSortOption: String, CaseIterable, Identifiable {
    case createdDate
    case dueDate
    case priority
    case title

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .createdDate: return "Created Date"
        case .dueDate: return "Due Date"
        case .priority: return "Priority"
        case .title: return "Title"
        }
    }
}
