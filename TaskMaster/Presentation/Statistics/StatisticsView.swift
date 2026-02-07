import SwiftUI

/// Statistics dashboard showing task analytics
struct StatisticsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StatisticsViewModel

    init() {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(
            fetchStatisticsUseCase: DIContainer.shared.fetchTaskStatisticsUseCase
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    LoadingView(message: "Loading statistics...")
                        .frame(height: 400)
                } else if let error = viewModel.error {
                    ErrorView(error: error) {
                        viewModel.loadStatistics()
                    }
                    .frame(height: 400)
                } else if let statistics = viewModel.statistics {
                    statisticsContent(statistics)
                }
            }
            .background(Color.primaryBackground)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadStatistics()
            }
        }
    }

    @ViewBuilder
    private func statisticsContent(_ stats: TaskStatistics) -> some View {
        VStack(spacing: 20) {
            // Overview cards
            overviewSection(stats)

            // Completion rate
            completionRateSection(stats)

            // Tasks by status
            statusDistributionSection(stats)

            // Tasks by priority
            priorityDistributionSection(stats)

            // Tasks by category
            categoryDistributionSection(stats)
        }
        .padding()
    }

    private func overviewSection(_ stats: TaskStatistics) -> some View {
        VStack(spacing: 12) {
            Text("Overview")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Total",
                    value: "\(stats.totalTasks)",
                    icon: "list.bullet",
                    color: .blue
                )

                StatCard(
                    title: "Completed",
                    value: "\(stats.completedTasks)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Active",
                    value: "\(stats.activeTasks)",
                    icon: "circle.lefthalf.filled",
                    color: .orange
                )

                StatCard(
                    title: "Overdue",
                    value: "\(stats.overdueTasks)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
            }
        }
    }

    private func completionRateSection(_ stats: TaskStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completion Rate")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(stats.completionRate * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)

                    Spacer()
                }

                ProgressView(value: stats.completionRate)
                    .tint(.green)
                    .scaleEffect(y: 2)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    private func statusDistributionSection(_ stats: TaskStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Distribution")
                .font(.headline)

            VStack(spacing: 8) {
                DistributionRow(
                    label: "To Do",
                    count: stats.totalTasks - stats.activeTasks - stats.completedTasks,
                    total: stats.totalTasks,
                    color: .gray
                )

                DistributionRow(
                    label: "In Progress",
                    count: stats.activeTasks,
                    total: stats.totalTasks,
                    color: .blue
                )

                DistributionRow(
                    label: "Completed",
                    count: stats.completedTasks,
                    total: stats.totalTasks,
                    color: .green
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    private func priorityDistributionSection(_ stats: TaskStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Distribution")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(TaskPriority.allCases.sorted(by: >), id: \.self) { priority in
                    if let count = stats.tasksByPriority[priority], count > 0 {
                        DistributionRow(
                            label: priority.displayName,
                            count: count,
                            total: stats.totalTasks,
                            color: priority.color
                        )
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }

    private func categoryDistributionSection(_ stats: TaskStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category Distribution")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    if let count = stats.tasksByCategory[category], count > 0 {
                        DistributionRow(
                            label: category.displayName,
                            count: count,
                            total: stats.totalTasks,
                            color: category.color
                        )
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct DistributionRow: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    StatisticsView()
}
