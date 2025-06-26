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

enum SectionLevel: Equatable {
    case empty // 0
    case low // (1 - 10) in 20
    case normal // (11-18) in 20
    case high // (19-20) in 20

    static let lowPercent = 50 // = 10 in 20
    static let highPercent = 90 // = 18 in 20

    static func defineLevel(progressPercent: Int) -> SectionLevel {
        guard progressPercent != 0 else {
            return empty
        }

        if progressPercent <= lowPercent {
            return low
        } else if progressPercent > highPercent {
            return high
        } else {
            return normal
        }
    }
}
