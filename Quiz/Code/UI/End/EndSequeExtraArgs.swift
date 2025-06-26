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

class EndSequeExtraArgs: Equatable {

    static let initValue = -1

    private(set) var gameMode: Mode = .unused

    private(set) var themeId: Int?

    private(set) var oldRecord: Int = EndSequeExtraArgs.initValue

    private(set) var point: Int = EndSequeExtraArgs.initValue

    private(set) var count: Int = EndSequeExtraArgs.initValue

    private(set) var errorQuestIds: Set<Int>?

    private(set) var isRewardedSuccess: Bool = false

    init(mode: Mode) {
        self.gameMode = mode
    }

    func isValid() -> Bool {
        return self.gameMode != .unused
                && self.oldRecord != EndSequeExtraArgs.initValue
                && self.point != EndSequeExtraArgs.initValue
                && self.count != EndSequeExtraArgs.initValue
    }
    
    // MARK: - Equatable
    
    static func == (lhs: EndSequeExtraArgs, rhs: EndSequeExtraArgs) -> Bool {
        return lhs.gameMode == rhs.gameMode &&
            lhs.themeId == rhs.themeId &&
            lhs.oldRecord == rhs.oldRecord &&
            lhs.point == rhs.point &&
            lhs.count == rhs.count &&
            lhs.errorQuestIds == rhs.errorQuestIds &&
            lhs.isRewardedSuccess == rhs.isRewardedSuccess
    }

    class Builder {
        private let sequeExtraArgs: EndSequeExtraArgs

        private init(mode: Mode) {
            self.sequeExtraArgs = EndSequeExtraArgs(mode: mode)
        }

        @discardableResult
        static func with(mode: Mode) -> Builder {
            return Builder(mode: mode)
        }

        @discardableResult
        func setThemeId(themeId: Int) -> Builder {
            sequeExtraArgs.themeId = themeId
            return self
        }

        @discardableResult
        func setOldRecord(oldRecord: Int) -> Builder {
            sequeExtraArgs.oldRecord = oldRecord
            return self
        }

        @discardableResult
        func setPoint(point: Int) -> Builder {
            sequeExtraArgs.point = point
            return self
        }

        @discardableResult
        func setCount(count: Int?) -> Builder {
            if let count = count {
                sequeExtraArgs.count = count
            }
            return self
        }

        @discardableResult
        func setErrorQuestIds(errorQuestIds: Set<Int>) -> Builder {
            sequeExtraArgs.errorQuestIds = errorQuestIds
            return self
        }

        @discardableResult
        func setIsRewardedOpen(isRewardedOpen: Bool) -> Builder {
            sequeExtraArgs.isRewardedSuccess = isRewardedOpen
            return self
        }

        func build() -> EndSequeExtraArgs {
            if sequeExtraArgs.isValid() {
                return sequeExtraArgs
            } else {
                fatalError("Args is invaid")
            }
        }
    }
}
