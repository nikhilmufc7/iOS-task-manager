import SwiftUI

/// A row view displaying a task in a list
struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Status toggle button
            Button(action: onToggle) {
                Image(systemName: task.status.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(task.status.color)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(task.status == .completed ? .secondary : .primary)
                    .strikethrough(task.status == .completed)

                // Description (if present)
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Metadata row
                HStack(spacing: 8) {
                    CategoryBadge(category: task.category, showLabel: false)
                    PriorityBadge(priority: task.priority, size: .small)

                    if let dueDate = task.dueDate {
                        DueDateBadge(dueDate: dueDate, isCompleted: task.status == .completed)
                    }

                    Spacer()
                }
            }

            Spacer(minLength: 0)

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.status.displayName)")
        .accessibilityHint("Double tap to view details")
    }
}

/// Badge showing due date with contextual styling
struct DueDateBadge: View {
    let dueDate: Date
    let isCompleted: Bool

    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }

    var isDueToday: Bool {
        Calendar.current.isDateInToday(dueDate)
    }

    var color: Color {
        if isCompleted {
            return .secondary
        } else if isOverdue {
            return .red
        } else if isDueToday {
            return .orange
        } else {
            return .secondary
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "calendar")
                .font(.system(size: 10))

            Text(formattedDate)
                .font(.caption2)
        }
        .foregroundColor(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15))
        .cornerRadius(4)
    }

    private var formattedDate: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(dueDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(dueDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: dueDate)
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: Task(
                title: "Complete iOS assignment",
                description: "Build a task management app with SwiftUI",
                status: .inProgress,
                priority: .high,
                category: .work,
                dueDate: Date().addingTimeInterval(86400)
            ),
            onToggle: {}
        )

        TaskRowView(
            task: Task(
                title: "Buy groceries",
                description: "Milk, eggs, bread",
                status: .todo,
                priority: .low,
                category: .shopping,
                dueDate: Date()
            ),
            onToggle: {}
        )

        TaskRowView(
            task: Task(
                title: "Workout",
                status: .completed,
                priority: .medium,
                category: .health
            ),
            onToggle: {}
        )
    }
}
