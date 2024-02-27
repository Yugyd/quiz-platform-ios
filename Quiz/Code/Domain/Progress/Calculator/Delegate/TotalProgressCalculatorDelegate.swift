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

class TotalProgressCalculatorDelegate: ProgressCalculatorProtocol {
    let progressCalculatorDelegates: [ProgressCalculatorProtocol]

    init() {
        progressCalculatorDelegates = [ArcadeProgressCalculatorDelegate(),
                                       MarathonProgressCalculatorDelegate(),
                                       SprintProgressCalculatorDelegate()]
    }

    func getRecord(point: Point) -> Int {
        fatalError("Non supported method")
    }

    func getRemain(point: Point) -> Int {
        fatalError("Non supported method")
    }

    func getRecordPercent(point: Point) -> Int {
        var total: Int = 0

        for delegate in progressCalculatorDelegates {
            total += delegate.getRecordPercent(point: point)
        }
        return total / progressCalculatorDelegates.count
    }

    func getRecordPercentByValue(value: Int, count: Int) -> Int {
        fatalError("Non supported method")
    }
}
