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
    
    var transactionListener: Task<Void, Error>?
    
    @Published var isSuccess = false
    
    @Published var pictures: [Picture] = (1...13).map { Picture(name: "Sample\($0)", mustPurchase: $0 > 4) }

    init() {
        transactionListener = listenForTransactions()
        
        Task {
            await requestProducts()
            await updateCurrentEntitlements()
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            products = try await Product.products(for: productIDs)
                .sorted(by: { $0.price > $1.price })
            print("Products successfully fetched: \(products)")
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    @MainActor
    func purchase(_ product: Product) async throws {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let transacitonVerification):
                await handle(transactionVerification: transacitonVerification)
                
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                print("User cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
                break
            }
        } catch {
            print("Failed to purchase the product!")
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
            // 거래가 확인됐을 경우 true
            isSuccess = true
            
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
            unlockPictures()
        case .consumable:
            purchasedConsumables.append(product)
            Persistence.increaseConsumablesCount()
        default:
            return
        }
    }
    
    private func unlockPictures() {
        for i in 4..<pictures.count {
            pictures[i].mustPurchase = false
        }
    }
}
