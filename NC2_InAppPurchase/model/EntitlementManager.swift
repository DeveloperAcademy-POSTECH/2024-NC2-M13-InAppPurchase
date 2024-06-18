//
//  EntitlementManager.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/18/24.
//

import SwiftUI

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.demo.app")!
    
    @AppStorage("hasPro", store: userDefaults)
    var hasPro: Bool = false
}
