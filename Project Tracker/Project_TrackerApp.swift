//
//  Project_TrackerApp.swift
//  Project Tracker
//
//  Created by hogar on 23/12/2025.
//

import SwiftUI

@main
struct Project_TrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
