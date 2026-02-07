import XCTest
import Combine
@testable import TaskMaster

final class FetchTasksUseCaseTests: XCTestCase {
    var sut: FetchTasksUseCase!
    var mockRepository: MockTaskRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        sut = FetchTasksUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchTasks_Success() {
        // Given
        let expectedTasks = [
            Task(title: "Task 1", priority: .high),
            Task(title: "Task 2", priority: .low),
            Task(title: "Task 3", priority: .medium)
        ]
        mockRepository.tasks = expectedTasks

        let expectation = expectation(description: "Fetch tasks")
        var receivedTasks: [Task]?

        // When
        sut.execute()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { tasks in
                    receivedTasks = tasks
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedTasks?.count, 3)
        XCTAssertEqual(receivedTasks?.first?.title, "Task 1")
    }

    func testFetchTasks_WithFilter_ReturnsFilteredTasks() {
        // Given
        mockRepository.tasks = [
            Task(title: "Active 1", status: .todo),
            Task(title: "Completed", status: .completed),
            Task(title: "Active 2", status: .inProgress)
        ]

        let expectation = expectation(description: "Fetch filtered tasks")
        var receivedTasks: [Task]?

        // When
        sut.execute(filter: .active)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { tasks in
                    receivedTasks = tasks
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedTasks?.count, 2)
        XCTAssertTrue(receivedTasks?.allSatisfy { $0.status != .completed } ?? false)
    }

    func testFetchTasks_WithPrioritySort_ReturnsSortedTasks() {
        // Given
        mockRepository.tasks = [
            Task(title: "Low", priority: .low),
            Task(title: "High", priority: .high),
            Task(title: "Urgent", priority: .urgent),
            Task(title: "Medium", priority: .medium)
        ]

        let expectation = expectation(description: "Fetch sorted tasks")
        var receivedTasks: [Task]?

        // When
        sut.execute(sortOption: .priority, ascending: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { tasks in
                    receivedTasks = tasks
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedTasks?.first?.priority, .urgent)
        XCTAssertEqual(receivedTasks?.last?.priority, .low)
    }

    func testFetchTasks_Failure() {
        // Given
        mockRepository.shouldFail = true
        mockRepository.error = MockError.fetchFailed

        let expectation = expectation(description: "Fetch tasks failure")
        var receivedError: Error?

        // When
        sut.execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedError)
    }
}
