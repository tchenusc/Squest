//
//  ContentView.swift
//  Squest
//
//  Created by Star Feng on 5/31/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var friendsListViewModel: FriendsListViewModel
    
    // State for presenting the quest completion pop-up globally
    @State private var showCompletionPopUp: Bool = false
    @State private var completedQuestData: (name: String, xp: Int, gold: Int)? = nil
    
    var body: some View {
        ZStack { // Use ZStack to overlay the pop-up and background effects
            TabView {
                HomeView(context: viewContext, userProfile: userProfile)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                LeadershipView()
                    .tabItem {
                        Label("Leadership", systemImage: "trophy.fill")
                    }
                
                FriendsView()
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                
                NavigationView { // Wrap ProfileView in a NavigationView
                    ProfileView(userProfile: userProfile)
                }
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
            }
            .tint(.blue)
            .onAppear {
#if DEBUG
                printAllBackgroundData(context: viewContext, userId: userProfile.current_user_id)
                printAllFriendListData(context: viewContext)
#endif
                // Call the user-specific seeding logic when the view appears and userProfile is available
                if let userId = userProfile.current_user_id {
                    seedBackgroundDataForUser(context: viewContext, userId: userId)
                    // Call the new method on the friendsListViewModel
                    Task { @MainActor in
                        await friendsListViewModel.setCurrentUserFriendList(context: viewContext, userId: userId)
                    }
                }
            }
            // Apply blur and disable interaction to the content behind the pop-up
            .blur(radius: showCompletionPopUp ? 5 : 0)
            .disabled(showCompletionPopUp)

            // Dimming overlay
            if showCompletionPopUp {
                Color.black.opacity(0.4) // Darken the background
                    .edgesIgnoringSafeArea(.all)
            }

            // Quest Completion Pop-up
            if showCompletionPopUp, let completedData = completedQuestData {
                QuestCompletedPopUp(
                    questName: completedData.name,
                    xp: completedData.xp,
                    gold: completedData.gold,
                    continueAction: {
                        self.showCompletionPopUp = false
                        self.completedQuestData = nil
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity)) // Animation for pop-up
                .zIndex(1) // Ensure pop-up is on top
            }
        }
    }
}

func printAllBackgroundData(context: NSManagedObjectContext, userId: UUID?) {
    guard let userId = userId else {
        print("---- No user ID available for BackgroundData fetch ----")
        return
    }
    
    let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
    request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
    
    do {
        let results = try context.fetch(request)
        print("---- BackgroundData entries for user \(userId.uuidString) ----")
        if results.isEmpty {
            print("No BackgroundData found for current user.")
        } else {
            for data in results {
                // Safely unwrap optional user_id for printing
                print("quest_id_IP: \(data.quest_id_IP), time_started: \(data.time_started?.description ?? "nil"), user_id: \(data.user_id?.uuidString ?? "nil")")
            }
        }
        print("-------------------------------")
    } catch {
        print("Error fetching BackgroundData: \(error)")
    }
}

// Function for user-specific conditional seeding
func seedBackgroundDataForUser(context: NSManagedObjectContext, userId: UUID) {
    let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
    // Check if a BackgroundData object already exists for this user ID
    request.predicate = NSPredicate(format: "user_id == %@", userId as CVarArg)
    
    do {
        let results = try context.fetch(request)
        
        // If no BackgroundData exists for this user, seed it
        if results.isEmpty {
            let backgroundData = BackgroundData(context: context)
            backgroundData.quest_id_IP = -1 // Default initial state
            backgroundData.time_started = Date()
            backgroundData.user_id = userId // Associate with the current user ID
            
            do {
                try context.save()
                print("✅ Seeded initial BackgroundData for user \(userId.uuidString).")
            } catch {
                print("❌ Failed to seed Core Data for user \(userId.uuidString): \(error)")
            }
        } else {
            print("ℹ️ BackgroundData already exists for user \(userId.uuidString), no seeding needed.")
        }
    } catch {
        print("Error checking for existing BackgroundData for user \(userId.uuidString): \(error)")
    }
}

func printAllFriendListData(context: NSManagedObjectContext) {
    print("\n---- FriendListMain entries ----")
    let mainRequest: NSFetchRequest<FriendListMain> = FriendListMain.fetchRequest()
    do {
        let results = try context.fetch(mainRequest)
        if results.isEmpty {
            print("No FriendListMain records found.")
        } else {
            for data in results {
                print("curr_user_id: \(data.curr_user_id?.uuidString ?? "nil"), dirty_bit: \(data.dirty_bit?.uuidString ?? "nil")")
            }
        }
    } catch {
        print("❌ Failed to fetch FriendListMain: \(error)")
    }
    print("-------------------------------")

    print("\n---- FriendList entries ----")
    let friendRequest: NSFetchRequest<FriendList> = FriendList.fetchRequest()
    do {
        let results = try context.fetch(friendRequest)
        if results.isEmpty {
            print("No FriendList records found.")
        } else {
            for data in results {
                print("name: \(data.name ?? "nil"), username: \(data.username ?? "nil"), lastActive: \(data.lastActive ?? "nil"), onQuest: \(data.onQuest ?? "nil"), profileInitials: \(data.profileInitials ?? "nil"), level: \(data.level), avatarUrl: \(data.avatarUrl ?? "nil")")
            }
        }
    } catch {
        print("❌ Failed to fetch FriendList: \(error)")
    }
    print("-------------------------------\n")
}

#Preview {
    let tempUser = UserProfile(userId: UUID(), email: "previewTest@mail.com")
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(tempUser) // Provide a UserProfile with a UUID for preview
        .environmentObject(AuthViewModel(userProfile: tempUser))
        .environmentObject(FriendsListViewModel())
}
