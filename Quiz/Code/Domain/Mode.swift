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

enum Mode: CaseIterable {
    case arcade
    case marathon
    case sprint
    case error
    case unused

    var title: String {
        switch self {
        case .arcade:
            return NSLocalizedString("TITLE_ARCADE", comment: "Arcade")
        case .marathon:
            return NSLocalizedString("TITLE_MARATHON", comment: "Marathon")
        case .sprint:
            return NSLocalizedString("TITLE_SPRINT", comment: "Sprint")
        case .error, .unused:
            fatalError("Non support mode title")
        }
    }

    func isContinueMode() -> Bool {
        switch self {
        case .arcade, .marathon, .error:
            return true
        case .sprint, .unused:
            return false
        }
    }
}
