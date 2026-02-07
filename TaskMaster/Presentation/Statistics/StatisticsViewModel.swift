import Foundation
import Combine

/// View model for statistics view
final class StatisticsViewModel: ObservableObject {
    @Published var statistics: TaskStatistics?
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchStatisticsUseCase: FetchTaskStatisticsUseCase
    private var cancellables = Set<AnyCancellable>()

    init(fetchStatisticsUseCase: FetchTaskStatisticsUseCase) {
        self.fetchStatisticsUseCase = fetchStatisticsUseCase
    }

    func loadStatistics() {
        isLoading = true
        error = nil

        fetchStatisticsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] statistics in
                    self?.statistics = statistics
                }
            )
            .store(in: &cancellables)
    }
}
