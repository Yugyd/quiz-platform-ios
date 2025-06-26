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

class GamePreferences: Preferences {

    var notification: Int {
        get {
            fatalError("Non supported pref item")
        }
        set {
            fatalError("Non supported pref item")
        }
    }

    var transition: Double
    var isVibration: Bool
    var isSorting: Bool
    var isAiEnabled: Bool
    var questTextSize: Int
    var answerTextSize: Int

    private let userPreferences: Preferences

    init(preferences: Preferences) {
        self.userPreferences = preferences

        self.transition = userPreferences.transition
        self.isVibration = userPreferences.isVibration
        self.isSorting = userPreferences.isSorting
        self.questTextSize = userPreferences.questTextSize
        self.answerTextSize = userPreferences.answerTextSize
        self.isAiEnabled = userPreferences.isAiEnabled
    }
}
