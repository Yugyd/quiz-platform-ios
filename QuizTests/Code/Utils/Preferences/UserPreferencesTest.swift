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

import XCTest
@testable import Quiz

class UserPreferencesTest: XCTestCase {
    var preferences: Preferences!

    override func setUp() {
        preferences = UserPreferences()
    }

    override func tearDown() {
        preferences = nil
    }

    // Notification
    func testNotificationDisable() {
        preferences.notification = NotificationPreference.disableValue
        let result = preferences.notification
        XCTAssertEqual(result, NotificationPreference.disableValue)
    }

    func testNotificationEnable() {
        preferences.notification = NotificationPreference(value: 9).value
        let result = preferences.notification
        XCTAssertEqual(result, 9)
    }

    func testNotificationNoValidValue() {
        preferences.notification = NotificationPreference(value: 99).value
        let result = preferences.notification
        XCTAssertEqual(result, NotificationPreference.disableValue)
    }

    // Transition
    func testTransitionDefault() {
        UserDefaults.standard.removeObject(forKey: UserPreferences.transitionKey)
        let result = preferences.transition
        XCTAssertEqual(result, TransitionPreference.defaultTransition.value)
    }

    func testTransitionChange() {
        preferences.transition = TransitionPreference.transition100.value
        let result = preferences.transition
        XCTAssertEqual(result, TransitionPreference.transition100.value)
    }

    // Vibration
    func testVibrationChange() {
        preferences.isVibration = true
        let result = preferences.isVibration
        XCTAssertEqual(result, true)
    }

    // Sorting
    func testSortChange() {
        preferences.isSorting = false
        let result = preferences.isSorting
        XCTAssertEqual(result, false)
    }

    func testDefaultTestSizes() {
        UserDefaults.standard.removeObject(forKey: UserPreferences.questTextSizeKey)
        UserDefaults.standard.removeObject(forKey: UserPreferences.answerTextSizeKey)

        let quest = preferences.questTextSize
        let answer = preferences.answerTextSize

        XCTAssertEqual(quest, -1)
        XCTAssertEqual(answer, -1)
    }
}
