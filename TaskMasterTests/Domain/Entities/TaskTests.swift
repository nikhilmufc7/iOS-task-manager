import XCTest
@testable import TaskMaster

final class TaskTests: XCTestCase {

    func testTask_IsOverdue_WhenDueDatePassed() {
        // Given
        let pastDate = Date().addingTimeInterval(-86400) // Yesterday
        let task = Task(
            title: "Overdue Task",
            status: .todo,
            dueDate: pastDate
        )

        // Then
        XCTAssertTrue(task.isOverdue)
    }

    func testTask_IsNotOverdue_WhenCompleted() {
        // Given
        let pastDate = Date().addingTimeInterval(-86400)
        let task = Task(
            title: "Completed Task",
            status: .completed,
            dueDate: pastDate
        )

        // Then
        XCTAssertFalse(task.isOverdue)
    }

    func testTask_IsNotOverdue_WhenNoDueDate() {
        // Given
        let task = Task(title: "No Due Date", dueDate: nil)

        // Then
        XCTAssertFalse(task.isOverdue)
    }

    func testTask_IsDueToday_WhenDueDateIsToday() {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let task = Task(title: "Due Today", dueDate: today)

        // Then
        XCTAssertTrue(task.isDueToday)
    }

    func testTask_IsDueSoon_WhenWithinWeek() {
        // Given
        let fiveDaysFromNow = Date().addingTimeInterval(5 * 86400)
        let task = Task(title: "Due Soon", dueDate: fiveDaysFromNow)

        // Then
        XCTAssertTrue(task.isDueSoon)
    }

    func testTask_IsNotDueSoon_WhenOverWeekAway() {
        // Given
        let tenDaysFromNow = Date().addingTimeInterval(10 * 86400)
        let task = Task(title: "Due Later", dueDate: tenDaysFromNow)

        // Then
        XCTAssertFalse(task.isDueSoon)
    }

    func testTaskPriority_Comparison() {
        // Given
        let low = TaskPriority.low
        let medium = TaskPriority.medium
        let high = TaskPriority.high
        let urgent = TaskPriority.urgent

        // Then
        XCTAssertTrue(low < medium)
        XCTAssertTrue(medium < high)
        XCTAssertTrue(high < urgent)
        XCTAssertFalse(urgent < high)
    }

    func testTaskStatus_DisplayNames() {
        // Given/When/Then
        XCTAssertEqual(TaskStatus.todo.displayName, "To Do")
        XCTAssertEqual(TaskStatus.inProgress.displayName, "In Progress")
        XCTAssertEqual(TaskStatus.completed.displayName, "Completed")
    }

    func testTaskCategory_HasUniqueIcons() {
        // Given
        let categories = TaskCategory.allCases

        // When
        let icons = Set(categories.map { $0.iconName })

        // Then
        XCTAssertEqual(icons.count, categories.count, "Each category should have a unique icon")
    }
}
