//
//  RefundView.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import SwiftUI
import StoreKit

struct RefundView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedTransactionID: UInt64?
    @State var isRefundRequestPresented: Bool = false
    
    var body: some View {
        Form {
            ForEach(store.entitlements, id: \.id) { transaction in
                HStack {
                    Text(transaction.purchaseDate.formatted())
                    Spacer()
                    Button("Refund") {
                        startRefund(transactionID: transaction.id)
                    }
                }
            }
        }
        .refundRequestSheet(
            for: selectedTransactionID ?? 0,
            isPresented: $isRefundRequestPresented
        ) { result in
            handleRefund(result: result)
        }
    }
    
    func startRefund(transactionID: UInt64) {
        selectedTransactionID = transactionID
        isRefundRequestPresented = true
    }
    
    func handleRefund(result: Result<StoreKit.Transaction.RefundRequestStatus, StoreKit.Transaction.RefundRequestError>) {
        switch result {
        case .success(.success):
            dismiss()
        default:
            return
        }
    }
}

struct RefundView_Previews: PreviewProvider {
    static var previews: some View {
        RefundView()
    }
}
