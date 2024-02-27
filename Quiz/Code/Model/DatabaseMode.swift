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

class DatabaseMode {

    let mode: Mode

    // HARD VALUE CONSRAIT IN DATABASE
    var id: Int {
        switch mode {
        case .unused:
            return -1
        case .error:
            return 0
        case .arcade:
            return 1
        case .marathon:
            return 2
        case .sprint:
            return 3
        }
    }

    init(mode: Mode) {
        self.mode = mode
    }

    func isUnusedOrDeprecatedMode() -> Bool {
        return mode == .unused || mode == .error
    }

    static func allCases() -> [DatabaseMode] {
        let result = Mode.allCases.map {
                    DatabaseMode(mode: $0)
                }
                .filter {
                    !$0.isUnusedOrDeprecatedMode()
                }
        return result
    }
}
