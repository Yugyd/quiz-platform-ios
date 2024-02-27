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

enum TransitionPreference: PreferenceData, CaseIterable {
    static let defaultTransition = TransitionPreference.transition2000

    case transition100
    case transition500
    case transition1000
    case transition2000
    case transition4000
    case transition8000

    var value: Double {
        switch self {
        case .transition100:
            return 0.1
        case .transition500:
            return 0.5
        case .transition1000:
            return 1.0
        case .transition2000:
            return 2.0
        case .transition4000:
            return 4.0
        case .transition8000:
            return 8.0
        }
    }

    var title: String {
        if self.value >= 1.0 {
            return "\(Int(self.value)) " + NSLocalizedString("TITLE_SEC", comment: "sec.")
        } else {
            return "\(self.value) " + NSLocalizedString("TITLE_SEC", comment: "sec.")
        }
    }

    static func instance(value: Double) -> TransitionPreference? {
        return TransitionPreference.allCases.first {
            $0.value == value
        }
    }
}
