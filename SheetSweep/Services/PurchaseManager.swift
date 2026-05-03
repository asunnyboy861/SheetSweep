import Foundation
import StoreKit

@Observable
final class PurchaseManager {
    var isProUser: Bool = false
    var isBusinessUser: Bool = false
    var isLifetimeUser: Bool = false
    var products: [Product] = []
    var freeUsageCount: Int = 0
    var maxFreeUsage: Int = 3

    private var monthlyProduct: Product?
    private var yearlyProduct: Product?
    private var lifetimeProduct: Product?

    static let shared = PurchaseManager()

    private var transactionListener: Task<Void, Never>?

    init() {
        freeUsageCount = UserDefaults.standard.integer(forKey: "freeUsageCount")
        transactionListener = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await updatePurchaseStatus()
                    await transaction.finish()
                }
            }
        }
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [
                "com.zzoutuo.SheetSweep.monthly",
                "com.zzoutuo.SheetSweep.yearly",
                "com.zzoutuo.SheetSweep.lifetime"
            ])
            products = storeProducts
            monthlyProduct = storeProducts.first { $0.id == "com.zzoutuo.SheetSweep.monthly" }
            yearlyProduct = storeProducts.first { $0.id == "com.zzoutuo.SheetSweep.yearly" }
            lifetimeProduct = storeProducts.first { $0.id == "com.zzoutuo.SheetSweep.lifetime" }
        } catch {}
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await updatePurchaseStatus()
                    await transaction.finish()
                    return true
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {}
        return false
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchaseStatus()
    }

    var isPremiumUser: Bool {
        isProUser || isBusinessUser || isLifetimeUser
    }

    var canUseFree: Bool {
        isPremiumUser || freeUsageCount < maxFreeUsage
    }

    func incrementUsage() {
        if !isPremiumUser {
            freeUsageCount += 1
            UserDefaults.standard.set(freeUsageCount, forKey: "freeUsageCount")
        }
    }

    private func updatePurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                switch transaction.productID {
                case "com.zzoutuo.SheetSweep.monthly":
                    isProUser = transaction.revocationDate == nil
                case "com.zzoutuo.SheetSweep.yearly":
                    isBusinessUser = transaction.revocationDate == nil
                case "com.zzoutuo.SheetSweep.lifetime":
                    isLifetimeUser = transaction.revocationDate == nil
                default:
                    break
                }
            }
        }
    }
}
