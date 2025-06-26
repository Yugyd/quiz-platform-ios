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

class PriceFormatter: PriceFormatterProtocol {

    func format(subscribe: Subscribe) -> String {
        if subscribe.period <= 31 {
            return "\(subscribe.localizedPrice) / " + String(localized: "subcribe_per_month", table: appLocalizable)
        } else if subscribe.period <= 93 {
            return "\(subscribe.localizedPrice) / " + String(localized: "subcribe_per_quarter", table: appLocalizable)
        } else if subscribe.period <= 365 {
            return "\(subscribe.localizedPrice) / " + String(localized: "subcribe_per_year", table: appLocalizable)
        } else {
            return "\(subscribe.localizedPrice)"
        }
    }
}
