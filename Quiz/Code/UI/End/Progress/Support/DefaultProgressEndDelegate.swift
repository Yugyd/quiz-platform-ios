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

class DefaultProgressEndDelegate: ProgressEndDelegate {
    static let defaultTitle = NSLocalizedString("TITLE_CURRENT_CATEHORY", comment: "Current category")

    func buildViewData(mode: Mode, themeTitle: String?, point: Int, count: Int) -> ViewData {
        let themeTitle = themeTitle ?? DefaultProgressEndDelegate.defaultTitle
        let progressCalculator = ProgressCalculator(mode: mode)

        let stubProgressPercent = 0
        let progressPercent = progressCalculator?.getRecordPercentByValue(value: point, count: count) ?? stubProgressPercent

        let outOf = NSLocalizedString("OUT_OF", comment: "out of")
        let progressSubtitle = "\(point) \(outOf) \(count)"
        return ViewData(title: themeTitle, progressPercent: progressPercent, subtitle: progressSubtitle)
    }
}
