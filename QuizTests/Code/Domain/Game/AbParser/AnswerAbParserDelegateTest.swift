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

class AnswerAbParserDelegateTest: XCTestCase {

    var abParser: AbQuestParser!

    override func setUp() {
        abParser = AnswerAbParserDelegate()
    }

    override func tearDown() {
        abParser = nil
    }

    func testIsValidType() {
        let quest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "only A is true",
                answers: [
                    "both statements are wrong",
                    "both statements are correct",
                    "only B is true",
                    "only A is true"],
                complexity: 3)

        let variantQuest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "only A is true",
                answers: [
                    "both statements are wrong",
                    "both statements are true",
                    "only B is true",
                    "only A is true"],
                complexity: 3)

        XCTAssertTrue(abParser.isAbQuest(quest))
        XCTAssertTrue(abParser.isAbQuest(variantQuest))
    }

    func testErrorIsTypeOtherQualifier() {
        let quest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "only A is true",
                answers: [
                    "both statements are wrong",
                    "both statements are correct",
                    "only B is true",
                    "only A is true"],
                complexity: 3)

        let variantQuest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "верно только А",
                answers: [
                    "both statements are wrong",
                    "both statements are correct",
                    "only B is true",
                    "only A is true"],
                complexity: 3)

        XCTAssertTrue(abParser.isAbQuest(quest))
        XCTAssertTrue(abParser.isAbQuest(variantQuest))
    }

    func testOtherQualifier() {
        let quest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "Bar",
                answers: [
                    "both statements are wrong",
                    "both statements are correct",
                    "only B is true",
                    "Bar"],
                complexity: 3)

        let variantQuest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "Foo",
                answers: [
                    "both statements are wrong",
                    "both statements are true",
                    "only B is true",
                    "Foo"],
                complexity: 3)

        let otherQuest = Quest(id: 99,
                quest: "FooBarBaz",
                trueAnswer: "Foo",
                answers: [
                    "both statements are wrong",
                    "both statements are true",
                    "only B is true",
                    "only A is true",
                    "Foo"],
                complexity: 3)

        XCTAssertFalse(abParser.isAbQuest(quest))
        XCTAssertFalse(abParser.isAbQuest(variantQuest))
        XCTAssertFalse(abParser.isAbQuest(otherQuest))
    }
}
