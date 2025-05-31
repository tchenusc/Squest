//
//  SquestApp.swift
//  Squest
//
//  Created by Star Feng on 5/31/25.
//

import SwiftUI

@main
struct SquestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
