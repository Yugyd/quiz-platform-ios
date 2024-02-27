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

class UserPreferences: Preferences {
    static let notificationKey = "com.yudyd.quiz.PREF_NOTIFICATION"
    static let transitionKey = "com.yudyd.quiz.PREF_TRANSITION"
    static let vibrationKey = "com.yudyd.quiz.PREF_VIBRATION"
    static let sortingKey = "com.yudyd.quiz.PREF_SORTING"
    static let questTextSizeKey = "com.yudyd.quiz.PREF_QUEST_TEXT_SIZE"
    static let answerTextSizeKey = "com.yudyd.quiz.PREF_ANSWER_TEXT_SIZE"

    var notification: Int {
        get {
            if userDefaults.object(forKey: UserPreferences.notificationKey) == nil {
                return NotificationPreference.disableValue
            } else {
                return userDefaults.integer(forKey: UserPreferences.notificationKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.notificationKey)
        }
    }

    var transition: Double {
        get {
            if userDefaults.object(forKey: UserPreferences.transitionKey) == nil {
                return TransitionPreference.defaultTransition.value
            } else {
                return userDefaults.double(forKey: UserPreferences.transitionKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.transitionKey)
        }
    }

    var isVibration: Bool {
        get {
            if userDefaults.object(forKey: UserPreferences.vibrationKey) == nil {
                return false
            } else {
                return userDefaults.bool(forKey: UserPreferences.vibrationKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.vibrationKey)
        }
    }

    var isSorting: Bool {
        get {
            if userDefaults.object(forKey: UserPreferences.sortingKey) == nil {
                return true
            } else {
                return userDefaults.bool(forKey: UserPreferences.sortingKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.sortingKey)
        }
    }

    /**
     * -1 Standard (?)
     * Small (1 - 15 [~ Subheadline])
     * Medium (2 - 20 [Title3: 20, Display, Regular])
     *  Large (3 - 28 [~ Title1])
     */
    var questTextSize: Int {
        get {
            if userDefaults.object(forKey: UserPreferences.questTextSizeKey) == nil {
                return -1 // Use class default - QuestTextSizePreference.medium
            } else {
                return userDefaults.integer(forKey: UserPreferences.questTextSizeKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.questTextSizeKey)
        }
    }

    /**
     * -1 Standard (?)
     * Small (1 - 15 [~ Subheadline])
     * Medium (2 - 17 [Body: 17, Text, Regualar])
     * Large (3 - 22 [~ Title2])
     */
    var answerTextSize: Int {
        get {
            if userDefaults.object(forKey: UserPreferences.answerTextSizeKey) == nil {
                return -1 // Use class default - AnswerTextSizePreference.medium
            } else {
                return userDefaults.integer(forKey: UserPreferences.answerTextSizeKey)
            }
        }

        set {
            userDefaults.set(newValue, forKey: UserPreferences.answerTextSizeKey)
        }
    }

    private let userDefaults: UserDefaults

    init() {
        self.userDefaults = UserDefaults.standard
    }
}
