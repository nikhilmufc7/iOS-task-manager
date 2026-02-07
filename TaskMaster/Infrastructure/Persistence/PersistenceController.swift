import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        for i in 0..<10 {
            let task = TaskEntity(context: viewContext)
            task.id = UUID()
            task.title = "Sample Task \(i + 1)"
            task.taskDescription = "This is a sample task description for task \(i + 1)"
            task.status = TaskStatus.allCases.randomElement()!.rawValue
            task.priority = TaskPriority.allCases.randomElement()!.rawValue
            task.category = TaskCategory.allCases.randomElement()!.rawValue
            task.createdAt = Date().addingTimeInterval(-Double.random(in: 0...604800))
            task.updatedAt = Date()

            if Bool.random() {
                task.dueDate = Date().addingTimeInterval(Double.random(in: -86400...604800))
            }
        }

        do {
            try viewContext.save()
        } catch {
            fatalError("Preview data creation failed: \(error)")
        }

        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskMaster")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Creates a background context for performing operations off the main thread
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    /// Saves the view context if there are changes
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
