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

enum ProfileItemIdentifier: CaseIterable {
    // Account section
    case signAccount
    // Social
    case telegram
    // Purchase section
    case pro
    case supportProject
    case restorePurchase
    // Link section
    case rateApp
    case shareFriend
    case otherApps
    // Settings section
    case notification
    case transition
    case sortQuest
    case vibration
    // Text size
    case questTextSize
    case answerTextSize
    // Feedback
    case reportError
    case privacyPollicy
}
