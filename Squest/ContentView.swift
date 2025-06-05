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
    
    // State for presenting the quest completion pop-up globally
    @State private var showCompletionPopUp: Bool = false
    @State private var completedQuestData: (name: String, xp: Int, gold: Int)? = nil
    
    var body: some View {
        ZStack { // Use ZStack to overlay the pop-up and background effects
            TabView {
                HomeView(context: viewContext)
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
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
            }
            .tint(.blue)
            .onAppear {
#if DEBUG
                printAllBackgroundData(context: viewContext, userId: userProfile.current_user_id)
#endif
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

func printAllBackgroundData(context: NSManagedObjectContext, userId: Int) {
    let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
    request.predicate = NSPredicate(format: "user_id == %d", userId)
    
    do {
        let results = try context.fetch(request)
        print("---- BackgroundData entries for user \(userId) ----")
        if results.isEmpty {
            print("No BackgroundData found for current user.")
        } else {
            for data in results {
                print("quest_id_IP: \(data.quest_id_IP), time_started: \(data.time_started?.description ?? "nil"), user_id: \(data.user_id)")
            }
        }
        print("-------------------------------")
    } catch {
        print("Error fetching BackgroundData: \(error)")
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(UserProfile(userId: 1)) // Provide a UserProfile for preview
}
