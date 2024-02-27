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

protocol ProgressCalculatorProtocol: AnyObject {

    /**
    * Returns the record number from the model (defines the desired value field).
    */
    func getRecord(point: Point) -> Int

    /**
     * Defines the remainder for the full progress from the model.
     */
    func getRemain(point: Point) -> Int

    /**
     * By determining the percentage of progress from the model.
     */
    func getRecordPercent(point: Point) -> Int

    /**
     * By determining the percentage of progress from two values.
     */
    func getRecordPercentByValue(value: Int, count: Int) -> Int
}
