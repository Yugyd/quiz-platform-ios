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
    case aiTasks
    case unused

    var title: String {
        switch self {
        case .arcade:
            return String(localized: "ds_game_mode_title_arcade", table: appLocalizable)
        case .marathon:
            return String(localized: "ds_game_mode_title_marathon", table: appLocalizable)
        case .sprint:
            return String(localized: "ds_game_mode_title_sprint", table: appLocalizable)
        case .error, .unused:
            fatalError("Non support mode title")
        case .aiTasks:
            return String(localized: "ds_game_mode_title_ai_tasks", table: appLocalizable)
        }
    }

    func isContinueMode() -> Bool {
        switch self {
        case .arcade, .marathon, .error, .aiTasks:
            return true
        case .sprint, .unused:
            return false
        }
    }
}
