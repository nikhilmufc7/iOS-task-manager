import SwiftUI
import UIKit

extension Color {
    // MARK: - Priority Colors
    static let priorityLow = Color.green.opacity(0.7)
    static let priorityMedium = Color.blue
    static let priorityHigh = Color.orange
    static let priorityUrgent = Color.red

    // MARK: - Status Colors
    static let statusTodo = Color.gray
    static let statusInProgress = Color.blue
    static let statusCompleted = Color.green

    // MARK: - Semantic Colors
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let primaryBackground = Color(.systemGroupedBackground)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let destructive = Color.red
}

extension TaskCategory {
    var color: Color {
        switch self {
        case .personal: return Color("CategoryPersonal")
        case .work: return Color("CategoryWork")
        case .shopping: return Color("CategoryShopping")
        case .health: return Color("CategoryHealth")
        case .finance: return Color("CategoryFinance")
        case .home: return Color("CategoryHome")
        }
    }
}

extension TaskPriority {
    var color: Color {
        switch self {
        case .low: return .priorityLow
        case .medium: return .priorityMedium
        case .high: return .priorityHigh
        case .urgent: return .priorityUrgent
        }
    }
}

extension TaskStatus {
    var color: Color {
        switch self {
        case .todo: return .statusTodo
        case .inProgress: return .statusInProgress
        case .completed: return .statusCompleted
        }
    }
}
