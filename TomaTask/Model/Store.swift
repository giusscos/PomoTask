//
//  Store.swift
//  TomaTask
//
//  Created by Giuseppe Cosenza on 31/10/24.
//

import Foundation
import StoreKit
import SwiftUI

@Observable
class Store {
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
    
    let productIdentifiers = ["pt_4999_1y_7d0", "pt_499_1m_7d0"]
    
    func fetchAvailableProducts() async throws -> [Product] {
        let products = try await Product.products(for: productIdentifiers)
        return products
    }
    
    func handlePurchase(purchase: PurchaseAction,product: Product) {
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
                    break
                case .unverified(let transaction, let verificationError):
                    // Handle unverified transactions based
                    // on your business model.
                    print(transaction, verificationError)
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
