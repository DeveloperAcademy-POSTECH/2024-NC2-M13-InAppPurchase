//
//  SupportView.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import SwiftUI
import StoreKit

struct SupportView: View {
    @State var isManageSubscriptionsSheetPresented: Bool = false
    @State var isOfferCodeRedepmtionPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Button("Subscription management") {
                    showManageSubscriptionSheet()
                }
                Button("Redeem code") {
                    showOfferCodeRedemption()
                }
                NavigationLink("Request a refund") {
                    RefundView()
                }
            }
            .manageSubscriptionsSheet(isPresented: $isManageSubscriptionsSheetPresented)
            .offerCodeRedemption(isPresented: $isOfferCodeRedepmtionPresented)
            
        }
        .navigationTitle("Support")
    }
    
    func showManageSubscriptionSheet() {
        isManageSubscriptionsSheetPresented = true
    }
    
    func showOfferCodeRedemption() {
        isOfferCodeRedepmtionPresented = true
    }
    
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
