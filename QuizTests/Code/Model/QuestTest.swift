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

class QuestTest: XCTestCase {

    func testErrorAnswers() {
        let quest = Quest(id: 1, quest: "BarBar", trueAnswer: "Foo", answers: ["Foo", "Bar", "Baz"], complexity: 1)
        XCTAssertFalse(quest.isValid())
    }
    
    func testErrorComplexity() {
        let quest = Quest(id: 1, quest: "BarBar", trueAnswer: "Foo", answers: ["Foo", "Bar", "Baz", "Foo"], complexity: 0)
        let questTwo = Quest(id: 1, quest: "BarBar", trueAnswer: "Foo", answers: ["Foo", "Bar", "Baz", "Foo"], complexity: 6)
        XCTAssertFalse(quest.isValid())
        XCTAssertFalse(questTwo.isValid())
    }
    
    func testErrorQuestText() {
        let quest = Quest(id: 1, quest: "Bar", trueAnswer: "Foo", answers: ["Foo", "Bar", "Baz", "Foo"], complexity: 3)
        XCTAssertFalse(quest.isValid())
    }
}
