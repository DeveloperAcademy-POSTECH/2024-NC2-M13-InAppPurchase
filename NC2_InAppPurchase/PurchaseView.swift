//
//  PurchaseView.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @EnvironmentObject var store: Store
    @AppStorage(Persistence.consumablesCountKey) var consumableCount: Int = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("You have")) {
                    HStack {
                        Spacer()
                        ProductView(
                            icon: "10 Pictures",
                            quantity: "\(consumableCount)"
                        )
                        
                        Spacer()
                        ProductView(
                            icon: "All Pictures",
                            quantity: "\(store.purchasedNonConsumables.count)"
                        )
                        Spacer()
                    }
                }
                
                Section(header: Text("To buy")) {
                    ForEach(store.products) {
                        product in
                        HStack {
                            Text(product.displayName)
                            Spacer()
                            Button("\(product.displayPrice)") {
                                Task {
                                    try await store.purchase(product)
                                }
                            }
                        }
                    }
                }
                
                Button("Restore purchases") {
                    Task {
                        try await AppStore.sync()
                    }
                }
                NavigationLink("Support", destination: SupportView())
            }
        }
    }
}

#Preview {
    PurchaseView()
}
