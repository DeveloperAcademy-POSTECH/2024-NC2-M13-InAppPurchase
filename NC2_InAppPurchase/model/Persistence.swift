//
//  Persistence.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import Foundation

class Persistence {
    static let consumablesCountKey = "consumablesCount"
    private static let storage = UserDefaults()
    
    static func increaseConsumablesCount() {
        let currentValue = storage.integer(forKey: Persistence.consumablesCountKey)
        storage.set(currentValue + 1, forKey: Persistence.consumablesCountKey)
    }
}
