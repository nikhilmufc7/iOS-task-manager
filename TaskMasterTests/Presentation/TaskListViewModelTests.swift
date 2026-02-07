import XCTest
import Combine
@testable import TaskMaster

final class TaskListViewModelTests: XCTestCase {
    var sut: TaskListViewModel!
    var mockRepository: MockTaskRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()

        let fetchUseCase = FetchTasksUseCase(repository: mockRepository)
        let createUseCase = CreateTaskUseCase(repository: mockRepository)
        let updateUseCase = UpdateTaskUseCase(repository: mockRepository)
        let deleteUseCase = DeleteTaskUseCase(repository: mockRepository)
        let toggleUseCase = ToggleTaskStatusUseCase(repository: mockRepository)

        sut = TaskListViewModel(
            fetchTasksUseCase: fetchUseCase,
            createTaskUseCase: createUseCase,
            updateTaskUseCase: updateUseCase,
            deleteTaskUseCase: deleteUseCase,
            toggleTaskStatusUseCase: toggleUseCase
        )
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    func testLoadTasks_Success_UpdatesTasksList() {
        // Given
        let expectedTasks = [
            Task(title: "Task 1"),
            Task(title: "Task 2")
        ]
        mockRepository.tasks = expectedTasks

        let expectation = expectation(description: "Tasks loaded")

        // Observe tasks property
        sut.$tasks
            .dropFirst() // Skip initial empty value
            .sink { tasks in
                if !tasks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.loadTasks()

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(sut.tasks.count, 2)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadTasks_Failure_SetsError() {
        // Given
        mockRepository.shouldFail = true
        mockRepository.error = MockError.fetchFailed

        let expectation = expectation(description: "Error set")

        sut.$error
            .dropFirst()
            .sink { error in
                if error != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.loadTasks()

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }

    func testFilteredTasks_WithSearchText_ReturnsFilteredResults() {
        // Given
        mockRepository.tasks = [
            Task(title: "Buy groceries", description: "Milk and bread"),
            Task(title: "Clean house", description: "Vacuum and mop"),
            Task(title: "Buy tickets", description: "Movie tickets")
        ]

        let expectation = expectation(description: "Tasks loaded")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if !tasks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadTasks()
        waitForExpectations(timeout: 1.0)

        // When
        sut.searchText = "buy"

        // Then
        XCTAssertEqual(sut.filteredTasks.count, 2)
        XCTAssertTrue(sut.filteredTasks.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("buy") ||
            $0.description.localizedCaseInsensitiveContains("buy")
        })
    }

    func testToggleTaskStatus_UpdatesTaskInList() {
        // Given
        let task = Task(title: "Test Task", status: .todo)
        mockRepository.tasks = [task]

        let expectation = expectation(description: "Task loaded")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if !tasks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadTasks()
        waitForExpectations(timeout: 1.0)

        let updateExpectation = expectation(description: "Task updated")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if let updatedTask = tasks.first, updatedTask.status == .completed {
                    updateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.toggleTaskStatus(task)

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(sut.tasks.first?.status, .completed)
    }

    func testDeleteTask_RemovesFromList() {
        // Given
        let task = Task(title: "Task to delete")
        mockRepository.tasks = [task]

        let expectation = expectation(description: "Task loaded")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if !tasks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadTasks()
        waitForExpectations(timeout: 1.0)

        let deleteExpectation = expectation(description: "Task deleted")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if tasks.isEmpty {
                    deleteExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.deleteTask(task)

        // Then
        waitForExpectations(timeout: 2.0)
        XCTAssertTrue(sut.tasks.isEmpty)
    }

    func testTaskCountByStatus_CalculatesCorrectly() {
        // Given
        mockRepository.tasks = [
            Task(title: "Todo 1", status: .todo),
            Task(title: "Todo 2", status: .todo),
            Task(title: "In Progress", status: .inProgress),
            Task(title: "Completed 1", status: .completed),
            Task(title: "Completed 2", status: .completed),
            Task(title: "Completed 3", status: .completed)
        ]

        let expectation = expectation(description: "Tasks loaded")
        sut.$tasks
            .dropFirst()
            .sink { tasks in
                if !tasks.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.loadTasks()
        waitForExpectations(timeout: 1.0)

        // When
        let counts = sut.taskCountByStatus

        // Then
        XCTAssertEqual(counts.todo, 2)
        XCTAssertEqual(counts.inProgress, 1)
        XCTAssertEqual(counts.completed, 3)
    }
}
