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
    
    var body: some View {
        TabView {
            HomeView()
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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
        }
        .tint(.blue)
        .onAppear {
#if DEBUG
            printAllBackgroundData(context: viewContext)
#endif
        }
    }
}

func printAllBackgroundData(context: NSManagedObjectContext) {
    let request: NSFetchRequest<BackgroundData> = BackgroundData.fetchRequest()
    
    do {
        let results = try context.fetch(request)
        print("---- BackgroundData entries ----")
        if results.isEmpty {
            print("No BackgroundData found.")
        } else {
            for data in results {
                print("quest_id_IP: \(data.quest_id_IP), time_started: \(data.time_started?.description ?? "nil")")
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
}
