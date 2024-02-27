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

class SubscribeFactory {

    func get(product: SKProduct) -> Subscribe {
        let period: Int
        switch product.subscriptionPeriod?.unit {
        case .month:
            let dayInMonth = 31
            period = (product.subscriptionPeriod?.numberOfUnits ?? 1) * dayInMonth
        case .year:
            let dayInYear = 365
            period = dayInYear
        default:
            period = 0
        }

        let localizedPriceValue: String
        if let localizedPrice = product.localizedPrice {
            localizedPriceValue = localizedPrice
        } else {
            localizedPriceValue = String(product.price.floatValue)
        }

        return Subscribe(id: product.productIdentifier,
                title: product.localizedTitle,
                price: Int(product.price.floatValue),
                localizedPrice: localizedPriceValue,
                period: period,
                isTrialOffer: false)
    }
}
