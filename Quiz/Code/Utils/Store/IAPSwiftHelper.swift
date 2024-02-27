//
//  Copyright 2024 Roman Likhachev
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import StoreKit
import SwiftyStoreKit
import TPInAppReceipt

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("com.yudyd.quiz.IAPHelperPurchaseNotification")
    static let IAPHelperRestoreNotification = Notification.Name("com.yudyd.quiz.IAPHelperRestoreNotification")
}

class IAPSwiftHelper: NSObject, IAPHelperProtocol {

    static let keyRestoreNotificationUserInfo = "isVerify"

    private var productIdentifiers: Set<String> = []

    private var products: [SKProduct] = []
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var buyProductRequestCompletionHandler: BuyProductsRequestCompletionHandler?
    private var refreshSubscriptionCompletionHandler: RefreshSubscriptionRequestCompletionHandler?

    private let subscribeFactory: SubscribeFactory
    private let decoder: DecoderProtocol
    private let dateFormatter: DateFormatter
    private let subscribeJsonMapper: SubscribeJsonMapper

    private var proSubscribeExpirationDate: Date?

    private var isVerifyDate: Bool = false

    init(keyDataSource: ProductKeyDataSourceProtocol,
         subscribeFactory: SubscribeFactory,
         decoder: DecoderProtocol,
         dateFormatterFactory: DateFormatterFactory,
         subscribeJsonMapper: SubscribeJsonMapper) {
        self.productIdentifiers = keyDataSource.getData()
        self.subscribeFactory = subscribeFactory
        self.decoder = decoder
        self.dateFormatter = dateFormatterFactory.get()
        self.subscribeJsonMapper = subscribeJsonMapper
        super.init()
    }

    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                self.completePurchase(needsFinishTransaction: purchase.needsFinishTransaction,
                        transaction: purchase.transaction,
                        productId: purchase.productId)
            }
        }
    }

    func shouldAddStorePaymentHandler() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return self.productIdentifiers.contains(product.productIdentifier)
        }
    }

    // MARK: - StoreKit API, IAPHelperProtocol

    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequestCompletionHandler = completionHandler

        SwiftyStoreKit.retrieveProductsInfo(productIdentifiers) { result in
            if !result.retrievedProducts.isEmpty {
                self.products = Array(result.retrievedProducts)
                let subscribes = result.retrievedProducts.map {
                            return self.subscribeFactory.get(product: $0)
                        }
                        .sorted { one, two in
                            return one.price < two.price
                        }

                self.productsRequestCompletionHandler?(true, subscribes)
                self.productsRequestCompletionHandler = nil
            } else {
                print("Failed to load list of products.")
                print("Error: \(String(describing: result.error?.localizedDescription))")

                self.products = []
                self.productsRequestCompletionHandler?(false, nil)
                self.productsRequestCompletionHandler = nil
            }
        }
    }

    func buyProduct(productId: String, completionHandler: @escaping BuyProductsRequestCompletionHandler) {
        buyProductRequestCompletionHandler = completionHandler

        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                self.completePurchase(needsFinishTransaction: purchase.needsFinishTransaction,
                        transaction: purchase.transaction,
                        productId: purchase.productId)

                self.buyProductRequestCompletionHandler?(.success, purchase.productId)
            case .error(let error):
                switch error.code {
                case .paymentCancelled:
                    self.buyProductRequestCompletionHandler?(.cancel, nil)
                    break
                default:
                    print((error as NSError).localizedDescription)
                    self.buyProductRequestCompletionHandler?(.error(msg: error.localizedDescription), nil)
                }
            }

            self.buyProductRequestCompletionHandler = nil
        }
    }

    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    func restorePurchases(completionHandler: @escaping RestoreRequestCompletionHandler) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                NotificationCenter.default.post(name: NSNotification.Name.IAPHelperRestoreNotification, object: nil, userInfo: [IAPSwiftHelper.keyRestoreNotificationUserInfo: false])
                completionHandler(false)
            } else if results.restoredPurchases.count > 0 {
                self.startVerifyReceipt(isRestored: true)
                completionHandler(true)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name.IAPHelperRestoreNotification, object: nil, userInfo: [IAPSwiftHelper.keyRestoreNotificationUserInfo: false])
                completionHandler(false)
            }
        }
    }

    func expirationDateFor() -> Date? {
        guard proSubscribeExpirationDate == nil else {
            return proSubscribeExpirationDate
        }

        if !isVerifyDate {
            startVerifyReceipt()
        }

        var items: [SubscribeDate] = [SubscribeDate]()
        for productId in productIdentifiers {
            if let encryptJson = UserDefaults.standard.string(forKey: productId) {
                let json = decoder.decrypt(encryptedText: encryptJson)
                if let subscribe = subscribeJsonMapper.decode(json: json) {
                    items.append(subscribe)
                }
            }
        }

        let subscribe = items.max { (one, two) -> Bool in
            return one.expiryTimeInterval < two.expiryTimeInterval
        }

        if let subscribe = subscribe {
            proSubscribeExpirationDate = Date(timeIntervalSince1970: subscribe.expiryTimeInterval)
        }

        return proSubscribeExpirationDate
    }

    // MARK: - Public func

    func verifyReceipt(callback: @escaping RefreshSubscriptionRequestCompletionHandler) {
        self.refreshSubscriptionCompletionHandler = callback

        InAppReceipt.refresh { (error) in
            if let err = error {
                print(err)
            } else {
                self.initializeReceipt()
            }
        }
    }

    func initializeReceipt() {
        do {
            let receipt = try InAppReceipt.localReceipt()
            try receipt.validate()
            processReceipt(receipt: receipt)
        } catch {
            print(error)
        }
    }

    private func processReceipt(receipt: InAppReceipt) {
        let productIds = self.productIdentifiers

        let activePurchases: [InAppPurchase] = receipt.activeAutoRenewableSubscriptionPurchases
        let expiryDate = activePurchases.map { item in
                    item.subscriptionExpirationDate ?? Date()
                }
                .max() ?? Date()

        if !receipt.hasActiveAutoRenewablePurchases {
            print("The user has never purchased \(productIds)")

            self.clearSubscribes(expiryDate: expiryDate, items: activePurchases)
            self.refreshSubscriptionCompletionHandler?(false, expiryDate, activePurchases)
            self.refreshSubscriptionCompletionHandler = nil

            return
        }

        if !activePurchases.isEmpty {
            self.proccessSubscribes(expiryDate: expiryDate, items: activePurchases)
            self.refreshSubscriptionCompletionHandler?(true, expiryDate, activePurchases)
            self.refreshSubscriptionCompletionHandler = nil
        }
    }

    // MARK: - Private func

    private func completePurchase(needsFinishTransaction: Bool, transaction: PaymentTransaction, productId: String) {
        switch transaction.transactionState {
        case .purchased, .restored:
            if needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(transaction)
            }

            self.startVerifyReceipt()
            break
        case .failed:
            let transaction = transaction as? SKPaymentTransaction
            if let transactionError = transaction?.error as NSError? {
                if transactionError.code != SKError.paymentCancelled.rawValue {
                    print("Transaction Error: \(String(describing: transaction?.error?.localizedDescription))")
                }
            }
            break
        case .purchasing, .deferred:
            break // do nothing
        default:
            break
        }
    }

    private func startVerifyReceipt(isRestored: Bool? = nil) {
        isVerifyDate = true
        self.verifyReceipt() { isVerify, expiryDate, _ in
            if isVerify {
                IocContainer.app.enablePro()
                NotificationCenter.default.post(name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
            }

            if let isRestored = isRestored, isRestored {
                NotificationCenter.default.post(name: NSNotification.Name.IAPHelperRestoreNotification, object: nil, userInfo: [IAPSwiftHelper.keyRestoreNotificationUserInfo: isVerify])
            }
        }
    }

    private func proccessSubscribes(expiryDate: Date, items: [InAppPurchase]) {
        guard expiryDate > Date() else {
            return
        }

        let validItems = items
                .filter { receiptItem in
                    isSubcribeDateValid(item: receiptItem)
                }
                .map { receiptItem in
                    SubscribeDate(
                            productId: receiptItem.productIdentifier,
                            expiryTimeInterval: receiptItem.subscriptionExpirationDate!.timeIntervalSince1970
                    )
                }
        saveProductInApp(subscribes: validItems)
    }

    private func clearSubscribes(expiryDate: Date, items: [InAppPurchase]) {
        guard expiryDate <= Date() else {
            return
        }

        productIdentifiers.forEach { productId in
            UserDefaults.standard.set(nil, forKey: productId)
        }
    }

    private func isSubcribeDateValid(item: InAppPurchase) -> Bool {
        return item.cancellationDate == nil && item.subscriptionExpirationDate != nil && item.subscriptionExpirationDate! > Date()
    }

    private func saveProductInApp(subscribes: [SubscribeDate]) {
        for productId in productIdentifiers {
            let subscribe = subscribes.first { item in
                item.productId == productId
            }

            if let subscribe = subscribe {
                if let json = subscribeJsonMapper.encode(subcribe: subscribe) {
                    let encryptJson = decoder.encrypt(decryptedText: json)
                    UserDefaults.standard.set(encryptJson, forKey: subscribe.productId)
                } else {
                    UserDefaults.standard.set(nil, forKey: subscribe.productId)
                }
            } else {
                UserDefaults.standard.set(nil, forKey: productId)
            }
        }

        proSubscribeExpirationDate = nil
    }
}
