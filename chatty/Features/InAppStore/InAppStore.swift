//
//  InAppStore.swift
//  chatty
//
//  Created by Ing. Ebu Celik, BSc on 26.08.23.
//

import StoreKit

class InAppStore: ObservableObject {
    private var productIds = ["donate"]

    @Published var products = [Product]()
    @Published var purchasedConsumables = Set<Product>()

    var transactionListener: Task<Void, Error>?

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
            products = try await Product.products(for: productIds)
        } catch {
            print(error)
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let transactionVerification):
            await handle(transactionVerification: transactionVerification)

        default:
            return
        }
    }

    @MainActor
    private func handle(transactionVerification result: VerificationResult<Transaction>) async {
        switch result {
        case let .verified(transaction):
            guard let product = self.products.first(
                where: { $0.id == transaction.productID }
            ) else { return }

            self.addPurchased(product)

            await transaction.finish()

        default:
            return
        }
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handle(transactionVerification: result)
            }
        }
    }

    private func updateCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            await self.handle(transactionVerification: result)
        }
    }

    private func addPurchased(_ product: Product) {
        switch product.type {
        case .consumable:
            purchasedConsumables.insert(product)

        default:
            return
        }
    }
}
