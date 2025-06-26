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

/**
  * Represents the specification for counting game progress. The delegate performs the count.
  */
class ProgressCalculator: ProgressCalculatorProtocol {

    /**
      * Performs progress counting
      */
    var delegate: ProgressCalculatorProtocol

    /**
     *Parameter delegate:
     * Used for client-side configuration, such as installing a generic calculator.
     */
    init(delegate: ProgressCalculatorProtocol) {
        self.delegate = delegate
    }

    /**
     * Self-determination of the delegate, based on the game mode, selects the appropriate delegate
     */
    convenience init?(mode: Mode) {
        switch mode {
        case .arcade:
            self.init(delegate: ArcadeProgressCalculatorDelegate())
        case .marathon:
            self.init(delegate: MarathonProgressCalculatorDelegate())
        case .sprint:
            self.init(delegate: SprintProgressCalculatorDelegate())
        case .aiTasks, .error, .unused:
            fatalError("Non valid game mode")
        }
    }

    /**
     * Returns the record number from the model (defines the desired value field).
     */
    func getRecord(point: Point) -> Int {
        delegate.getRecord(point: point)
    }

    /**
     * Defines the remainder for the full progress from the model.
     */
    func getRemain(point: Point) -> Int {
        delegate.getRemain(point: point)
    }

    /**
     * By determining the percentage of progress from the model.
     */
    func getRecordPercent(point: Point) -> Int {
        delegate.getRecordPercent(point: point)
    }

    /**
     * By determining the percentage of progress from two values.
     */
    func getRecordPercentByValue(value: Int, count: Int) -> Int {
        delegate.getRecordPercentByValue(value: value, count: count)
    }
}
