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

class PointTest: XCTestCase {
    var errorPoint: Point!
    var validPoint: Point!
    
    override func setUp() {
        errorPoint = Point(count: 100, arcade: 0, marathon: 0, sprint: 1)
        validPoint = Point(count: 100, arcade: 0, marathon: 0, sprint: 0)
    }

    override func tearDown() {
        errorPoint = nil
        validPoint = nil
    }
    
    func testNoEmpty() {
        XCTAssertFalse(errorPoint.isEmpty())
    }
    
    func testEmpty() {
        XCTAssertTrue(validPoint.isEmpty())
    }
}
