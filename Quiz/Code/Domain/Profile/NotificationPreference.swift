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

class NotificationPreference: PreferenceData {
    static let defaultNotification = NotificationPreference(value: NotificationPreference.disableValue)
    static let disableValue: Int = -1
    static let minValue = 0
    static let maxValue = 23
    static let values: [Int] = Array(minValue...maxValue)

    enum Identifier {
        case disable
        case enable
    }

    var value: Int
    var title: String

    init(value: Int) {
        self.title = String(value)

        if value > NotificationPreference.minValue && value < NotificationPreference.maxValue {
            self.value = value

            let hour = String(self.value)
            if hour.count == 1 {
                self.title = "0\(hour).00"
            } else {
                self.title = "\(hour).00"
            }
        } else {
            self.value = NotificationPreference.disableValue
            self.title = NSLocalizedString("TITLE_NOT_SELECTED", comment: "Not selected")
        }
    }
}
