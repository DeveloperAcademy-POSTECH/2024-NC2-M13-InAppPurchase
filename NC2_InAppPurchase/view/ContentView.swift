//
//  ContentView.swift
//  NC2_InAppPurchase
//
//  Created by 신승아 on 6/17/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isPurchase = false
    
    var body: some View {
        NavigationStack {
            NavigationLink("Purchase", destination: PurchaseView())
            NavigationLink("Pictures", destination: GridView())
                .navigationTitle("Catcha")
                .toolbar {
                    NavigationLink{
                        SupportView()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
        }
    }
}

//#Preview {
//    ContentView()
//}
