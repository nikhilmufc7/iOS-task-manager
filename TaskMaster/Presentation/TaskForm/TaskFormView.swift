import SwiftUI

/// Form view for creating or editing a task
struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TaskFormViewModel

    let onSave: (Task) -> Void

    enum Mode {
        case create
        case edit(Task)

        var title: String {
            switch self {
            case .create: return "New Task"
            case .edit: return "Edit Task"
            }
        }
    }

    init(mode: Mode, onSave: @escaping (Task) -> Void) {
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: TaskFormViewModel(
            mode: mode,
            createTaskUseCase: DIContainer.shared.createTaskUseCase,
            updateTaskUseCase: DIContainer.shared.updateTaskUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $viewModel.title)
                        .accessibilityLabel("Task title")

                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Task description")
                }

                Section("Organization") {
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(TaskStatus.allCases) { status in
                            Label(status.displayName, systemImage: status.iconName)
                                .tag(status)
                        }
                    }

                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(TaskPriority.allCases) { priority in
                            Label(priority.displayName, systemImage: priority.iconName)
                                .tag(priority)
                        }
                    }

                    Picker("Category", selection: $viewModel.category) {
                        ForEach(TaskCategory.allCases) { category in
                            Label(category.displayName, systemImage: category.iconName)
                                .tag(category)
                        }
                    }
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $viewModel.hasDueDate)

                    if viewModel.hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $viewModel.dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                if let error = viewModel.error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(viewModel.mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .disabled(viewModel.isSaving)
            .onChange(of: viewModel.didSave) { didSave in
                if didSave, let task = viewModel.savedTask {
                    onSave(task)
                    dismiss()
                }
            }
        }
    }
}

#Preview("Create") {
    TaskFormView(mode: .create) { _ in }
}

#Preview("Edit") {
    TaskFormView(
        mode: .edit(Task(
            title: "Sample Task",
            description: "This is a sample task",
            priority: .high,
            category: .work
        ))
    ) { _ in }
}
