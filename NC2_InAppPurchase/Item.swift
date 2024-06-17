//
//  Item.swift
//  NC2_InAppPurchase
//
//  Created by 신승아 on 6/17/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
