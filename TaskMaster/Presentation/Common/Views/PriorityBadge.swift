import SwiftUI

/// A badge displaying task priority with icon and color
struct PriorityBadge: View {
    let priority: TaskPriority
    let size: BadgeSize

    enum BadgeSize {
        case small, medium, large

        var fontSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .body
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 14
            case .large: return 16
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }

    init(priority: TaskPriority, size: BadgeSize = .medium) {
        self.priority = priority
        self.size = size
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.iconName)
                .font(.system(size: size.iconSize))

            Text(priority.displayName)
                .font(size.fontSize)
                .fontWeight(.medium)
        }
        .foregroundColor(priority.color)
        .padding(.horizontal, size.padding * 1.5)
        .padding(.vertical, size.padding)
        .background(priority.color.opacity(0.15))
        .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: 16) {
        PriorityBadge(priority: .low)
        PriorityBadge(priority: .medium)
        PriorityBadge(priority: .high)
        PriorityBadge(priority: .urgent)
    }
    .padding()
}
