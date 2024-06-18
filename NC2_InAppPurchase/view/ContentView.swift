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
            GridView()
                .toolbar {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink{
                            SupportView()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Image("logo")
                            .resizable()
                            .frame(width: 100, height: 25)
                            .padding(.horizontal, 10)
                        
                    }
                }
        }
    }
}

//#Preview {
//    ContentView()
//}
