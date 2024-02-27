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

class ErrorProgressEndDelegate: ProgressEndDelegate {
    static let errorTitle = NSLocalizedString("TITLE_WORK_ERROR", comment: "Work on mistakes")

    func buildViewData(mode: Mode, themeTitle: String?, point: Int, count: Int) -> ViewData {
        let outOf = NSLocalizedString("OUT_OF", comment: "out of")
        return ViewData(
                title: ErrorProgressEndDelegate.errorTitle,
                progressPercent: Percent.calculatePercent(value: point, count: count),
                subtitle: "\(point) \(outOf) \(count)"
        )
    }
}
