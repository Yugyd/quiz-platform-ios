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

class PromoDataSource: PromoDataSourceProtocol {

    private var data: [PromoViewData] = []
    private var featureManager: FeatureManager

    init(featureManager: FeatureManager) {
        self.featureManager = featureManager
    }

    func getData() -> [PromoViewData] {
        if !(data.isEmpty) {
            return data
        }

        let correctPromo = PromoViewData(
                imageQualifier: "ic_rocket_launch",
                title: String(localized: "pro_title_work_error", table: appLocalizable),
                subtitle: String(localized: "pro_title_work_error_info", table: appLocalizable)
        )
        data.append(correctPromo)
        if featureManager.isFeatureEnabled(FeatureToggle.ad) == true {
            let adPromo = PromoViewData(
                    imageQualifier: "ic_ad_off",
                    title: String(localized: "pro_title_ad_off", table: appLocalizable),
                    subtitle: String(localized: "pro_title_ad_off_info", table: appLocalizable)
            )
            data.append(adPromo)
        }

        return data
    }
}
