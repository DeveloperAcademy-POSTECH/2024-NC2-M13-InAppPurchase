//
//  NC2_InAppPurchaseApp.swift
//  NC2_InAppPurchase
//
//  Created by 신승아 on 6/17/24.
//

import SwiftUI

@main
struct NC2_InAppPurchaseApp: App {
    @StateObject var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
