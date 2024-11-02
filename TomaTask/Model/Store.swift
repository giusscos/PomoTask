//
//  Store.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import Foundation
import StoreKit
import SwiftUI

@Observable class Store {
    let productIdentifiers = ["pt_4999_1y_7d0", "pt_499_1m_7d0"]
    var products: [Product] = []
    var transactionId: UInt64 = 0
    var unlockAccess: Bool = false
    
    init() {
        Task {
            await observeTransactions()
        }
    }
    
    private func observeTransactions() async {
        // Ascolta costantemente le transazioni
        for await result in Transaction.updates {
            await handle(transactionResult: result)
        }
    }
    
    private func handle(transactionResult: VerificationResult<StoreKit.Transaction>) async {
            do {
                let transaction = try checkVerified(transactionResult)
                
                await processTransaction(transaction)
                
                
                await transaction.finish()
            } catch {
                
                print("Errore nella verifica della transazione: \(error)")
        }
    }
    
    private func checkVerified(_ result: VerificationResult<StoreKit.Transaction>) throws -> StoreKit.Transaction {
        
        switch result {
            case .unverified:
                throw StoreKitError.notEntitled
            case .verified(let transaction):
                return transaction
        }
    }
    
    private func processTransaction(_ transaction: StoreKit.Transaction) async {
        print("Transazione completata con successo: \(transaction)")
    }
        
    func fetchAvailableProducts() async throws {
        let productsResult = try await Product.products(for: productIdentifiers)
        
        products = productsResult
        
        for product in products {
            await isPurchased(product: product)
        }
    }
    
    func isPurchased(product: Product?) async {
        guard let product = product else {
//            print("Error product")
            return
        }
        guard let verificationResult = await product.currentEntitlement else {
//            print("No entitlement found for product: \(product)")
            return
        }
        
        switch verificationResult {
//        case .verified(let transaction):
        case .verified(let transaction):
            // Check the transaction and give the user access to purchased
            // content as appropriate.
            self.unlockAccess = true
            self.transactionId = transaction.id
            break
//        case .unverified(let transaction, let verificationError):
        case .unverified(_, _):
            // Handle unverified transactions based
            // on your business model.
            self.unlockAccess = false
            break
        }
    }
    
    func handlePurchase(purchase: PurchaseAction, product: Product) {
        Task {
            let result = try? await purchase(product)
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    // Give the user access to purchased content.
                    // Complete the transaction after providing
                    // the user access to the content.
                    await transaction.finish()
                    self.unlockAccess = true
                    break
                case .unverified(_, _):
                    // Handle unverified transactions based
                    // on your business model.
                    break
                }
            case .pending:
                // The purchase requires action from the customer.
                // If the transaction completes,
                // it's available through Transaction.updates.
                break
            case .userCancelled:
                // The user canceled the purchase.
                break
            case .none:
                break
            @unknown default:
                break
            }
        }
    }
}
