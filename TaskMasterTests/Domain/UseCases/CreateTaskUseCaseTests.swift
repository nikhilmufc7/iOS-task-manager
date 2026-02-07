import XCTest
import Combine
@testable import TaskMaster

final class CreateTaskUseCaseTests: XCTestCase {
    var sut: CreateTaskUseCase!
    var mockRepository: MockTaskRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        sut = CreateTaskUseCase(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    func testCreateTask_WithValidTitle_Success() {
        // Given
        let task = Task(
            title: "New Task",
            description: "Task description",
            priority: .high
        )

        let expectation = expectation(description: "Create task")
        var createdTask: Task?

        // When
        sut.execute(task)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { task in
                    createdTask = task
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(createdTask)
        XCTAssertEqual(createdTask?.title, "New Task")
        XCTAssertEqual(mockRepository.tasks.count, 1)
    }

    func testCreateTask_WithEmptyTitle_Fails() {
        // Given
        let task = Task(title: "   ", description: "Description")

        let expectation = expectation(description: "Create task fails")
        var receivedError: Error?

        // When
        sut.execute(task)
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
        XCTAssertTrue(receivedError is TaskError)
        XCTAssertEqual(mockRepository.tasks.count, 0)
    }

    func testCreateTask_UpdatesTimestamp() {
        // Given
        let oldDate = Date(timeIntervalSince1970: 0)
        let task = Task(
            title: "Task",
            updatedAt: oldDate
        )

        let expectation = expectation(description: "Create task updates timestamp")
        var createdTask: Task?

        // When
        sut.execute(task)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { task in
                    createdTask = task
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(createdTask)
        XCTAssertNotEqual(createdTask?.updatedAt, oldDate)
    }
}
