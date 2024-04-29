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

enum SectionItem: CaseIterable {
    case top
    case social
    case settings
    case purchase
    case link
    case feedback

    var title: String {
        switch self {
        case .social:
            return NSLocalizedString("PROFILE_SECTION_SOCIAL", comment: "Social media")
        case .purchase:
            return NSLocalizedString("PROFILE_SECTION_PURCHASE", comment: "Purchases")
        case .link:
            return NSLocalizedString("PROFILE_SECTION_LINK", comment: "Please us")
        case .settings:
            return NSLocalizedString("PROFILE_SECTION_SETTINGS", comment: "Settings")
        case .feedback:
            return NSLocalizedString("PROFILE_SECTION_FEEDBACK", comment: "Feedback")
        case .top:
           return ""
        }
    }
}
