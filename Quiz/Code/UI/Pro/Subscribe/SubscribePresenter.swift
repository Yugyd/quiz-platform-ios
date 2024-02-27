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

import Foundation

class SubscribePresenter: SubscribePresenterProtocol {

    var subscribes: [Subscribe] = []

    var priceFormatter: PriceFormatterProtocol

    private weak var rootView: SubscribeViewProtocol?

    private let dataSource: ProductKeyDataSourceProtocol
    private var iapHelper: IAPHelperProtocol

    init(iapHelper: IAPHelperProtocol) {
        self.iapHelper = iapHelper;

        self.dataSource = ProductKeyDataSource()
        self.priceFormatter = PriceFormatter()
    }

    func attachView(rootView: SubscribeViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        self.rootView?.visibleProgressView(true)

        iapHelper.requestProducts(completionHandler: { [weak self] (isSuccess, subscribes) in
            DispatchQueue.main.async { [weak self] in
                self?.handleData(isSuccess: isSuccess, data: subscribes)
            }
        })
    }

    func buyProduct(productId: String) {
        self.rootView?.visibleProgressView(true)
        iapHelper.buyProduct(
                productId: productId,
                completionHandler: { [weak self] (buyState, productId) in
                    DispatchQueue.main.async { [weak self] in
                        self?.rootView?.visibleProgressView(false)

                        switch buyState {
                        case .success, .cancel:
                            break
                        case .error:
                            self?.rootView?.showErrorAlert(type: .buyProduct)
                        }
                    }
                })
    }

    func canMakePayments() -> Bool {
        return iapHelper.canMakePayments()
    }

    func restorePurchases() {
        self.rootView?.visibleProgressView(true)
        iapHelper.restorePurchases { (isSuccess) in
            self.rootView?.visibleProgressView(false)
        }
    }

    func testClearTransactions() {
        //return iapHelper.clearTransactions()
    }

    // MARK: - Private

    private func handleData(isSuccess: Bool, data: [Subscribe]?) {
        self.rootView?.visibleProgressView(false)

        if isSuccess, let data = data {
            self.subscribes = data
            self.rootView?.updateCollection()
        } else {
            self.rootView?.showErrorAlert(type: .requestProducts)
        }
    }
}
