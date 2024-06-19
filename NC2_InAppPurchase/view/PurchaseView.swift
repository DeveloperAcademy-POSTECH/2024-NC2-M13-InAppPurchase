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
    private let features: [String] = ["10장 더보기 선택시 가려진 사진 10장을 더 볼 수 있습니다.",
                                      "평생보기 선택시 가려진 모든 사진을 볼 수 있고, 매주 업데이트 됩니다."]
    
    @State private var selectedProduct: Product? = nil
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
//        if store.isSuccess {
//            // 평생구매시 뷰 변경 확인, 10장 더 보기는 nonConsumable로 변경할 필요 o
//            // 둘 다 nonConsumable구매이지만 서로 뷰의 변화가 달라야 함 -> HOW?
//            hasSubscriptionView
//        } else {
            NavigationStack {
                
                VStack {
                    
                    proAccessView
                    featuresView
                    productsListView
                    purchaseButtonView
                    
                    Button("Restore purchases") {
                        Task {
                            try await AppStore.sync()
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    Button {
                        dismiss()
                    } label: {
                        Text("닫기")
                    }
                }
            }
            // 뷰가 나타날 때 requestProducts를 호출하려 products를 가져오도록 함
            .onAppear {
                Task {
                    await store.requestProducts()
                    print("Products fetched: \(store.products)")
                }
            }
//        }
    }
    
    // 구매 성공시 View가 변화하는 테스트용 View
//    private var hasSubscriptionView: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "crown.fill")
//                .foregroundStyle(.yellow)
//                .font(Font.system(size: 100))
//            
//            Text("You've Unlocked Pro Access")
//                .font(.system(size: 30.0, weight: .bold))
//                .fontDesign(.rounded)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//        }
//        .ignoresSafeArea(.all)
//    }
    
    private var proAccessView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("🐱")
                .frame(width: 100, height: 100)
                .font(.system(size: 100))
            
            Text("귀여운 고양이 사진 더 보고싶냥..?")
                .frame(height: 80)
                .font(.system(size: 30, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("고양이 사진을 구매하고 매일 힐링하세요.")
                .font(.system(size: 17.0, weight: .semibold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
    }
    
    private var featuresView: some View {
        List(features, id: \.self) { feature in
            HStack(alignment: .center) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 22.5, weight: .medium))
                    .foregroundStyle(.blue)
                
                Text(feature)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)
            }
            .listRowSeparator(.hidden)
            .frame(height: 50)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .padding(.vertical, 30)
    }
    
    private var productsListView: some View {
        List(store.products, id: \.self) { product in
            SubscriptionItemView(product: product, selectedProduct: $selectedProduct)
        }
        .scrollDisabled(true)
        .listStyle(.plain)
        .listRowSpacing(2.5)
        .frame(height: CGFloat(store.products.count) * 90, alignment: .bottom)
    }
    
    private var purchaseButtonView: some View {
        Button(action: {
            if let selectedProduct = selectedProduct {
                Task {
                    try await store.purchase(selectedProduct)
                }
            } else {
                print("Please select a product before purchasing.")
            }
        }) {
            RoundedRectangle(cornerRadius: 12.5)
                .overlay {
                    Text("Purchase")
                        .foregroundStyle(.white)
                        .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                }
        }
        .padding(.horizontal, 20)
        .frame(height: 46)
        .disabled(selectedProduct == nil)
    }
}

struct SubscriptionItemView: View {
    var product: Product
    @Binding var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .stroke(selectedProduct == product ? .blue : .black, lineWidth: 1.0)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            
            HStack {
                VStack(alignment: .leading, spacing: 8.5) {
                    Text(product.displayName)
                        .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                    
                    Text("단돈 \(product.displayPrice)에 마음의 평화를 ?!")
                        .font(.system(size: 14.0, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: selectedProduct == product ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedProduct == product ? .blue : .gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 65, alignment: .center)
        }
        .onTapGesture {
            selectedProduct = product
        }
        .listRowSeparator(.hidden)
    }
}

//#Preview {
//    PurchaseView()
//}
