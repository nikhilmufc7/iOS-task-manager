import SwiftUI

@main
struct TaskMasterApp: App {
    @StateObject private var container = DIContainer.shared

    init() {
        setupAppearance()
    }

    var body: some Scene {
        WindowGroup {
            TaskListView()
                .environmentObject(container)
        }
    }

    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
