import SwiftUI

/// Detailed view of a single task with edit and delete actions
struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TaskDetailViewModel

    let onUpdate: () -> Void

    init(task: Task, onUpdate: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(
            task: task,
            updateTaskUseCase: DIContainer.shared.updateTaskUseCase,
            deleteTaskUseCase: DIContainer.shared.deleteTaskUseCase,
            toggleTaskStatusUseCase: DIContainer.shared.toggleTaskStatusUseCase
        ))
        self.onUpdate = onUpdate
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    headerSection

                    // Description section
                    if !viewModel.task.description.isEmpty {
                        descriptionSection
                    }

                    // Metadata section
                    metadataSection

                    // Due date section
                    if let dueDate = viewModel.task.dueDate {
                        dueDateSection(dueDate: dueDate)
                    }

                    // Timestamps section
                    timestampsSection
                }
                .padding()
            }
            .background(Color.primaryBackground)
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.showingEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            viewModel.showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingEditSheet) {
                TaskFormView(mode: .edit(viewModel.task)) { _ in
                    onUpdate()
                    dismiss()
                }
            }
            .alert("Delete Task", isPresented: $viewModel.showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteTask()
                }
            } message: {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
            .onChange(of: viewModel.didDelete) { didDelete in
                if didDelete {
                    onUpdate()
                    dismiss()
                }
            }
        }
    }

    // MARK: - Subviews
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    viewModel.toggleStatus()
                } label: {
                    Image(systemName: viewModel.task.status.iconName)
                        .font(.system(size: 28))
                        .foregroundColor(viewModel.task.status.color)
                }
                .buttonStyle(PlainButtonStyle())

                Text(viewModel.task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .strikethrough(viewModel.task.status == .completed)

                Spacer()
            }

            HStack(spacing: 8) {
                Text(viewModel.task.status.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(viewModel.task.status.color)
                    .cornerRadius(8)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)

            Text(viewModel.task.description)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(12)
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 0) {
                MetadataRow(
                    icon: viewModel.task.priority.iconName,
                    iconColor: viewModel.task.priority.color,
                    label: "Priority",
                    value: viewModel.task.priority.displayName
                )

                Divider()
                    .padding(.leading, 44)

                MetadataRow(
                    icon: viewModel.task.category.iconName,
                    iconColor: viewModel.task.category.color,
                    label: "Category",
                    value: viewModel.task.category.displayName
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }

    private func dueDateSection(dueDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Due Date")
                .font(.headline)
                .foregroundColor(.primary)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(viewModel.task.isOverdue ? .red : .blue)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(dueDate, style: .date)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(dueDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if viewModel.task.isOverdue {
                    Text("Overdue")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                } else if viewModel.task.isDueToday {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(6)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }

    private var timestampsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Timestamps")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 0) {
                MetadataRow(
                    icon: "clock",
                    iconColor: .gray,
                    label: "Created",
                    value: formatDate(viewModel.task.createdAt)
                )

                Divider()
                    .padding(.leading, 44)

                MetadataRow(
                    icon: "clock.arrow.circlepath",
                    iconColor: .gray,
                    label: "Updated",
                    value: formatDate(viewModel.task.updatedAt)
                )
            }
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Metadata Row Component

struct MetadataRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(iconColor)
                .frame(width: 28)

            Text(label)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding()
    }
}

#Preview {
    TaskDetailView(
        task: Task(
            title: "Complete iOS Assignment",
            description: "Build a task management app with SwiftUI following clean architecture principles",
            status: .inProgress,
            priority: .high,
            category: .work,
            dueDate: Date().addingTimeInterval(86400)
        )
    ) {}
}
