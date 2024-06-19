# 2024-NC2-M13-In-App Purchase
## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About Augmented Reality

인앱 결제(In-App Purchase)는 애플의 iOS와 macOS 애플리케이션에서 디지털 콘텐츠나 구독 서비스를 판매할 수 있도록 해주는 기술입니다. 이를 통해 사용자는 앱 내에서 추가 콘텐츠나 기능을 구매할 수 있으며, 개발자는 수익을 창출할 수 있습니다. 인앱 결제는 주로 다음과 같은 항목을 판매하는 데 사용됩니다.

1. **소모성 구매**: 사용자가 여러 번 구매할 수 있는 항목으로, 사용 후 소모되는 형태입니다. 예를 들어, 게임 내 화폐나 파워업 등이 이에 해당합니다.
2. **비소모성 구매**: 한 번 구매하면 영구적으로 사용할 수 있는 항목으로, 여러 기기에서 동일한 계정으로 사용할 수 있습니다. 예를 들어, 앱의 프리미엄 기능이나 특정 도구 등이 이에 해당합니다.
3. **자동 갱신 구독**: 일정 기간마다 자동으로 갱신되는 구독 서비스입니다. 예를 들어, 월간 또는 연간 구독 서비스가 이에 해당합니다.
4. **비갱신 구독**: 일정 기간 동안만 유효한 구독 서비스로, 기간이 끝나면 사용자가 다시 구독을 갱신해야 합니다.

## 🎯 What we focus on?
1. 4가지 결제유형 중 비소진형 아이템 유형을 선택해서 구현해본다.
    - 4가지 결제유형을 구현하는 방식은 비슷하므로, 우리의 Use Case에 제일 적합한 방식인 비소모성 구매에 집중했습니다.
2. 인앱결제 프로세스를 완벽히 이해한다.
    - 인앱결제 API는 커스텀할 수 있는 부분이 적고 이미 완성된 상태였기 때문에, 단순한 구현보다는 이론적인 이해에 초점을 맞췄다.

## 💼 Use Case
🐱 귀여운 고양이 사진을 인앱구매를 통해 사용자가 소장할 수 있도록 하자!

## 🖼️ Prototype
<img width="800" alt="Ideation" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M13-InAppPurchase/blob/main/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA%202024-06-19%20%E1%84%8B%E1%85%A9%E1%84%8C%E1%85%A5%E1%86%AB%209.23.38.png?raw=true">

## 🛠️ About Code
```swift
import SwiftUI
import StoreKit

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    /// 구매 가능한 제품 ID의 배열
    let productIDs: [String] = ["addPhotos", "allPhotos"]
    /// 사용자가 구매한 제품 ID를 저장하는 집합
    var purchasedProductIDs: Set<String> = []
    /// 사용자가 구매할 수 있는 제품 목록을 저장하는 배열
    @Published var products: [Product] = []
    
    @Published var photoCount = 2
    
    /// 트랜잭션 업데이트를 관찰
    private var updates: Task<Void, Never>? = nil
    
    override init() {
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: StoreKit2 API
extension SubscriptionsManager {

    /// 앱스토어 커넥트에 있는 Products 가져오는 메서드
    func loadProducts() async {
        do {
            let allProducts = try await Product.products(for: productIDs)
            self.products = allProducts
                .filter { !isProductPurchased($0.id) }
                .sorted(by: { $0.price > $1.price })
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    private func isProductPurchased(_ productID: String) -> Bool {
        if productID == "addPhotos" {
            return UserDefaults.standard.tenPhotosAccess
        } else if productID == "allPhotos" {
            return UserDefaults.standard.allPhotosAccess
        }
        return false
    }
    
    /// Products 를 구매하는 메서드
    func buyProduct(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                // 성공적으로 구매된 트랜잭션
                await transaction.finish()
                await self.updatePurchasedProducts()

            case let .success(.unverified(_, error)):
                // 구매는 성공했지만 트랜잭션이나 영수증을 검증할 수 없는 경우
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // 구매가 대기 상태인 경우
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
    
    /// 현재 유효한 트랜잭션을 확인하고, 이를 기반으로 사용자가 구매한 제품 목록을 업데이트
    func updatePurchasedProducts() async {
        // Transaction.currentEntitlements: 사용자의 현재 유효한 구매 내역
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            // 트랜잭션이 취소되지 않음
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            }
            // 트랜잭션이 취소됨
            else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    /// 구매내역 복원
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
```
