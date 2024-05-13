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

struct Quest: Identifiable, Equatable, Hashable {
    static let minQuestLength = 5
    static let minAnswerLength = 1
    static let maxComplexity = 5
    static let minComplexity = 1
    static let answerCount = 4

    let id: Int
    let quest: String
    let trueAnswer: String
    let answers: [String]
    let complexity: Int
    let category: Int
    let section: Int

    static var count = 0

    func isValid() -> Bool {
        return quest.count > Quest.minQuestLength
                && !(trueAnswer.isEmpty)
                && answers.contains(trueAnswer)
                && answers.count == Quest.answerCount
                && !(answers.filter({ $0.isEmpty }).count >= 1)
                && (complexity >= Quest.minComplexity && complexity <= Quest.maxComplexity)
    }
}
