//
//  Store.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//


import Foundation
import StoreKit

//alias
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo //The Product.SubscriptionInfo.RenewalInfo provides information about the next subscription renewal period.
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState // the renewal states of auto-renewable subscriptions.

@Observable
class Store {
    private var subscriptions: [Product] = []
    var purchasedSubscriptions: [Product] = []
    private var subscriptionGroupStatus: RenewalState?
    var isLoading: Bool = true

    private let productIds: [String] = ["pt_499_1w", "pt_4999_1y_7d0"]
    
    let groupId: String = "21571698"
    
    var updateListenerTask : Task<Void, Error>? = nil
    
    init() {
        //start a transaction listern as close to app launch as possible so you don't miss a transaction
        updateListenerTask = listenForTransactions()
        
        Task { [weak self] in
            await self?.requestProducts()
            await self?.updateCustomerProductStatus()
            await MainActor.run { [self] in self?.isLoading = false }

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                await self?.updateCustomerProductStatus()
            }
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    // deliver products to the user
                    await self.updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("transaction failed verification")
                }
            }
        }
    }
    
    // Request the products
    @MainActor
    func requestProducts() async {
        do {
            // request from the app store using the product ids (hardcoded)
            subscriptions = try await Product.products(for: productIds)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    // purchase the product
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            //Check whether the transaction is verified. If it isn't,
            //this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            //The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            //Always finish a transaction.
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        // Build the next list first, then assign once. Clearing `purchasedSubscriptions`
        // mid-refresh briefly makes `isSubscribed` false and remounts ProgressiveTimerView
        // (locked paywall flash + dial animating from 0 every ~60s poll).
        var nextPurchased: [Product] = []

        for await result in Transaction.currentEntitlements {
            do {
                //Check whether the transaction is verified. If it isn't, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = await product(for: transaction.productID) {
                        nextPurchased.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                print("failed updating products")
            }
        }

        let nextIDs = nextPurchased.map(\.id)
        let currentIDs = purchasedSubscriptions.map(\.id)
        if nextIDs != currentIDs {
            purchasedSubscriptions = nextPurchased
        }
    }

    /// Immediately adds a product to purchasedSubscriptions after a verified purchase,
    /// before Transaction.currentEntitlements reflects the new entitlement.
    @MainActor
    func grantProduct(_ product: Product) {
        if !purchasedSubscriptions.contains(where: { $0.id == product.id }) {
            purchasedSubscriptions.append(product)
        }
    }

    /// Prefer the cached catalog; fetch by ID if missing so entitlements still unlock Pro.
    @MainActor
    private func product(for productID: String) async -> Product? {
        if let cached = subscriptions.first(where: { $0.id == productID }) {
            return cached
        }
        do {
            let products = try await Product.products(for: [productID])
            if let product = products.first {
                subscriptions.append(product)
                return product
            }
        } catch {
            print("Failed product lookup for \(productID): \(error)")
        }
        return nil
    }
}

public enum StoreError: Error {
    case failedVerification
}
