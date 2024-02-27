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

class GameSequeExtraArgs {

    private static let recordDefault = 0

    private (set) var gameMode: Mode?
    private (set) var themeId: Int?

    private (set) var sectionId: Int?
    private (set) var record: Int = GameSequeExtraArgs.recordDefault

    init(mode: Mode?, themeId: Int?) {
        self.gameMode = mode
        self.themeId = themeId
    }

    func isValid() -> Bool {
        return gameMode != nil && gameMode != .unused && themeId != nil
    }

    class Builder {
        private let sequeExtraArgs: GameSequeExtraArgs

        private init(mode: Mode?, themeId: Int?) {
            self.sequeExtraArgs = GameSequeExtraArgs(mode: mode, themeId: themeId)
        }

        @discardableResult
        static func with(mode: Mode?, themeId: Int?) -> Builder {
            return Builder(mode: mode, themeId: themeId)
        }

        @discardableResult
        func setSectionId(sectionId: Int?) -> Builder {
            sequeExtraArgs.sectionId = sectionId
            return self
        }

        @discardableResult
        func setRecord(record: Int?) -> Builder {
            sequeExtraArgs.record = record ?? GameSequeExtraArgs.recordDefault
            return self
        }

        func build() -> GameSequeExtraArgs? {
            if sequeExtraArgs.isValid() {
                return sequeExtraArgs
            } else {
                return nil
            }
        }
    }
}
