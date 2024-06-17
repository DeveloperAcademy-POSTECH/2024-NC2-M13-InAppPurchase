//
//  Store.swift
//  NC2_InAppPurchase
//
//  Created by 조우현 on 6/17/24.
//

import StoreKit

class Store: ObservableObject {
    private var productIDs = ["10_pictures", "all_pictures"]
    @Published var products = [Product]()
    
    @Published var purchasedNonConsumables = Set<Product>()
    @Published var purchasedConsumables = [Product]()
    
    @Published var entitlements = [Transaction]()
    
    var transacitonListener: Task<Void, Error>?
    
    init() {
        transacitonListener = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCurrentEntitlements()
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            print("Products successfully fetched: \(products)")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let transacitonVerification):
            await handle(transactionVerification: transacitonVerification)
        default:
            return
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionVerification: result)
            }
        }
    }
    
    @MainActor
    @discardableResult
    private func handle(transactionVerification result: VerificationResult<Transaction>) async -> Transaction? {
        switch result {
        case let .verified(transaction):
            guard let product = self.products.first(where: { $0.id == transaction.productID}) else { return transaction }
            
            guard !transaction.isUpgraded else { return transaction }
            self.addPurchased(product)
            
            await transaction.finish()
            
            return transaction
        default:
            return nil
        }
    }
    
    @MainActor
    private func updateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = await self.handle(transactionVerification: result) {
                entitlements.append(transaction)
            }
        }
    }
    
    private func addPurchased(_ product: Product) {
        switch product.type {
        case .nonConsumable:
            purchasedNonConsumables.insert(product)
        case .consumable:
            purchasedConsumables.append(product)
            Persistence.increaseConsumablesCount()
        default:
            return
        }
    }
}
