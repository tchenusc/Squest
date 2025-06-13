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
    @StateObject var userProfile: UserProfile
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var friendsListViewModel: FriendsListViewModel
    
    init() {
        // Seed data on app launch if needed
        let userProfile = UserProfile(userId: nil, email: "test@mail.com")
        _userProfile = StateObject(wrappedValue: userProfile)
        _authViewModel = StateObject(wrappedValue: AuthViewModel(userProfile: userProfile))
        _friendsListViewModel = StateObject(wrappedValue: FriendsListViewModel())
        
        //clearCoreData(context: persistenceController.container.viewContext)
        seedFriendListMainIfNeeded(context: persistenceController.container.viewContext)
        printAllBackgroundData(context: persistenceController.container.viewContext)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(userProfile)
                        .environmentObject(authViewModel)
                        .environmentObject(friendsListViewModel)
                } else {
                    WelcomeView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                authViewModel.restoreSession()
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
                    print("🧾 quest_id_IP: \(questID), time_started: \(timeStarted), user_id: \(userID ?? UUID())")
                }
            }
        } catch {
            print("❌ Failed to fetch BackgroundData: \(error)")
        }
    }
    
    // Function for user-specific conditional seeding of FriendListMain
    func seedFriendListMainIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<FriendListMain> = FriendListMain.fetchRequest()

        do {
            let results = try context.fetch(request)

            if results.isEmpty {
                let friendListMain = FriendListMain(context: context)
                friendListMain.curr_user_id = nil
                friendListMain.dirty_bit = nil

                do {
                    try context.save()
                    print("✅ Seeded initial FriendListMain.")
                } catch {
                    print("❌ Failed to seed FriendListMain: \(error)")
                }
            } else {
                print("ℹ️ FriendListMain already exists, no seeding needed.")
            }
        } catch {
            print("Error checking for existing FriendListMain: \(error)")
        }
    }
}
