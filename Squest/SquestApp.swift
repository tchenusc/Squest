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
    @StateObject var userProfile = UserProfile(userId: 1)
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Seed data on app launch if needed
        //clearCoreData(context: persistenceController.container.viewContext)
        seedIfNeeded(context: persistenceController.container.viewContext)
        //printAllBackgroundData(context: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(userProfile)
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    func seedIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        let results = try? context.fetch(request)
        
        if results?.isEmpty ?? true {
            let backgroundData = BackgroundData(context: context)
            backgroundData.quest_id_IP = -1
            backgroundData.time_started = Date()
            backgroundData.user_id = 1 // Set initial user_id
            
            do {
                try context.save()
                print("✅ Seeded initial Quest.")
            } catch {
                print("❌ Failed to seed Core Data: \(error)")
            }
        }
    }
    
    func clearCoreData(context: NSManagedObjectContext) {
        let entities = context.persistentStoreCoordinator?.managedObjectModel.entities

        entities?.forEach { entity in
            if let name = entity.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                do {
                    try context.execute(deleteRequest)
                } catch {
                    print("❌ Failed to delete \(name): \(error)")
                }
            }
        }

        do {
            try context.save()
            print("✅ Cleared all Core Data entities")
        } catch {
            print("❌ Save failed after deletion: \(error)")
        }
    }
    
    func printAllBackgroundData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.isEmpty {
                print("📭 No BackgroundData records found.")
            } else {
                for data in results {
                    let questID = data.quest_id_IP
                    let timeStarted = data.time_started?.description ?? "nil"
                    let userID = data.user_id
                    print("🧾 quest_id_IP: \(questID), time_started: \(timeStarted), user_id: \(userID)")
                }
            }
        } catch {
            print("❌ Failed to fetch BackgroundData: \(error)")
        }
    }
}
