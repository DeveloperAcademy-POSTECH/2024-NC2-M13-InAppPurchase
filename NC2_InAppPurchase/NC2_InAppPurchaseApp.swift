//
//  NC2_InAppPurchaseApp.swift
//  NC2_InAppPurchase
//
//  Created by 신승아 on 6/17/24.
//

import SwiftUI
import SwiftData

@main
struct NC2_InAppPurchaseApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
