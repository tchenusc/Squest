//
//  SquestApp.swift
//  Squest
//
//  Created by Star Feng on 5/31/25.
//

import SwiftUI
import CoreData

@main
struct SquestApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        // Seed data on app launch if needed
        seedIfNeeded(context: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func seedIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        
        guard count == 0 else { return }
        
        let backgroundData = BackgroundData(context: context)
        backgroundData.quest_id_IP = -1
        backgroundData.time_started = Date()
        
        do {
            try context.save()
            print("✅ Seeded initial Quest.")
        } catch {
            print("❌ Failed to seed Core Data: \(error)")
        }
    }
}
