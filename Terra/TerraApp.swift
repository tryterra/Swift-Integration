//
//  TerraApp.swift
//  Terra
//
//  Created by Elliott Yu on 23/09/2021.
//

import SwiftUI
import HealthKit

@main
struct TerraApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

