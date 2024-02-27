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

class NotificationValueItemDataDelegate: ValueItemDataDelegate {

    var itemData = NotificationPreference.values.map {
        NotificationPreference(value: $0)
    }

    func loadData() -> [String] {
        return itemData.map {
            $0.title
        }
    }

    func setPreferencesValue(preferences: Preferences, index: Int) {
        let item = itemData[index]
        preferences.notification = item.value
    }

    func getCurrentIndexByPreferencesValue(preferences: Preferences) -> Int {
        let item = getCurrentItemByPreferencesValue(preferences: preferences) as! NotificationPreference
        return itemData.firstIndex(where: { $0.value == item.value })!
    }

    func getCurrentItemByPreferencesValue(preferences: Preferences) -> PreferenceData {
        let value = preferences.notification
        return itemData.first(where: { $0.value == value }) ?? NotificationPreference.defaultNotification
    }
}
