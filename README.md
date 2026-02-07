# TaskMaster

A task management app for iOS built with SwiftUI and Clean Architecture.

## How to run the app

```bash
open TaskMaster.xcodeproj
```

Select a simulator and hit Run (⌘+R). That's it.

## Architecture

I went with Clean Architecture instead of simpler patterns like basic MVVM because it makes the codebase easier to test and maintain long-term. The separation between domain, data, and presentation layers means business logic stays isolated from UI and persistence concerns. Also i could have gone with RIBs but given the app's size, it felt like overkill.

### Layer Structure

**Domain** - Pure Swift business logic with no framework dependencies
- `Entities/` - Task model and related types
- `UseCases/` - Business operations (create, update, delete, fetch)
- `RepositoryInterfaces/` - Protocols that define data contracts

**Data** - Handles persistence with Core Data
- `Repositories/` - Concrete implementations of repository protocols
- `DataSources/` - Core Data abstraction layer
- `Models/` - Core Data entity mappings

**Presentation** - SwiftUI views and view models
- `TaskList/` - Main list view with search and filters
- `TaskDetail/` - Individual task view
- `TaskForm/` - Create/edit task form
- `Statistics/` - Analytics dashboard
- `Common/` - Reusable UI components

**Infrastructure** - Cross-cutting utilities
- `Persistence/` - Core Data stack setup
- `Extensions/` - Helper extensions for Date, View, etc.

The dependency rule is simple: arrows point inward. Presentation depends on Domain, Data depends on Domain, but Domain depends on nothing.

## Why This Structure?

**Protocol-based repositories** make it trivial to swap implementations or add mocks for testing. The domain layer has zero awareness of Core Data, SwiftUI, or any other framework.

**Use cases** encapsulate business rules. Want to add validation before creating a task? It goes in the use case, not scattered across view models.

**MVVM + Combine** for the presentation layer because it's a natural fit with SwiftUI. View models expose `@Published` properties that views observe. No manual bindings needed.

## What It Does

Core features:
- Create, read, update, delete tasks
- Task priorities (low, medium, high, urgent)
- Categories (personal, work, shopping, health, finance, home)
- Due dates with overdue tracking
- Status tracking (todo, in progress, completed)

Additional stuff:
- Search with real-time filtering
- Sort by date, priority, or title
- Filter by status or overdue
- Statistics dashboard showing completion rates
- Swipe to delete
- Pull to refresh
- Dark mode support

## Project Structure

```
TaskMaster/
├── App/
│   ├── TaskMasterApp.swift          # App entry point
│   └── DIContainer.swift             # Dependency injection
├── Domain/
│   ├── Entities/
│   │   └── Task.swift                # Task model + enums
│   ├── UseCases/                     # Business operations
│   └── RepositoryInterfaces/         # Repository protocols
├── Data/
│   ├── Repositories/                 # Repository implementations
│   ├── DataSources/                  # Core Data abstraction
│   └── Models/                       # Core Data entities
├── Presentation/
│   ├── TaskList/                     # Main list + view model
│   ├── TaskDetail/                   # Task detail + view model
│   ├── TaskForm/                     # Create/edit form
│   ├── Statistics/                   # Analytics view
│   └── Common/Views/                 # Reusable components
├── Infrastructure/
│   ├── Persistence/                  # Core Data stack
│   └── Extensions/                   # Utilities
└── Resources/
    ├── Assets.xcassets               # Colors and icons
    └── TaskMaster.xcdatamodeld       # Core Data model
```

## Technical Decisions

**Combine over async/await** - Combine works well with SwiftUI's reactive nature and makes it easy to chain operations like debouncing search. Plus it demonstrates understanding of reactive programming patterns.

**Core Data over simpler options** - Could've used UserDefaults or JSON files, but Core Data gives us proper querying, relationships, and migration support if we need to extend the model later.

**Use cases instead of fat view models** - Keeps view models focused on presentation logic. Business rules live in use cases where they can be reused and tested independently.

**No coordinator pattern** - SwiftUI's navigation is declarative enough that coordinators would add unnecessary complexity for an app this size.

## Code Quality Notes

- No force unwraps or force casts
- Memory safe with `[weak self]` in closures
- Type-safe enums instead of string constants
- Comprehensive error handling with custom error types
- All major classes documented

## Testing

Tests are included in `TaskMasterTests/`:

**Domain Layer Tests**
- `TaskTests` - Business logic validation (overdue detection, date logic)
- `FetchTasksUseCaseTests` - Testing filtering and sorting
- `CreateTaskUseCaseTests` - Validation and error handling

**Presentation Layer Tests**
- `TaskListViewModelTests` - State management, search, filtering

**Mocks**
- `MockTaskRepository` - Configurable mock for testing without real persistence

Run tests in Xcode with ⌘+U or via command line:
```bash
xcodebuild test -project TaskMaster.xcodeproj -scheme TaskMaster \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

The architecture makes testing straightforward - use cases are tested with mock repositories, view models with mock use cases. Everything is protocol-based so mocking is trivial.

## Future Improvements

Given more time, I'd add:
- Local notifications for due tasks
- Task attachments (photos, files)
- Subtasks or checklist items
- Shared task lists

## Requirements

- iOS 17.0+
- Xcode 15.0+

The app starts with no data. Create a few tasks to test features like search, filtering, and statistics.
