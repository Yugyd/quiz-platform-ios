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

import XCTest
@testable import Quiz

class PercentTest: XCTestCase {

    func testMax() {
        let max = Percent.calculatePercent(value: 100, count: 100)
        XCTAssertEqual(max, 100)
    }

    func testMin() {
        let min = Percent.calculatePercent(value: 0, count: 100)
        XCTAssertEqual(min, 0)
    }

    func testMiddle() {
        let middle = Percent.calculatePercent(value: 50, count: 100)
        XCTAssertEqual(middle, 50)
    }

    func testErrorMax() {
        let errorMax = Percent.calculatePercent(value: 101, count: 100)
        XCTAssertEqual(errorMax, 100)
    }

    func testErrorMin() {
        let errorMin = Percent.calculatePercent(value: -1, count: 100)
        XCTAssertEqual(errorMin, 0)
    }

    func testNoMin() {
        let result = Percent.calculatePercent(value: 1, count: 1000)
        XCTAssertNotEqual(result, 1)
    }

    func testNoMax() {
        let result = Percent.calculatePercent(value: 999, count: 1000)
        XCTAssertNotEqual(result, 100)
    }

    func testValidOnePercent() {
        let result = Percent.calculatePercent(value: 2, count: 300)
        XCTAssertNotEqual(result, 1)
    }

    func testValidZeroPercent() {
        let result = Percent.calculatePercent(value: 1, count: 300)
        XCTAssertNotEqual(result, 1)
    }
}
