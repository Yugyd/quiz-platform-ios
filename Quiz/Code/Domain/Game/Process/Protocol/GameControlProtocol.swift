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

protocol GameControlProtocol {

    var gameMode: Mode { get set }

    /**
      * Stores the last relevant question, installed after loading from the database.
      * May be zero if loading from the database fails.
      */
    var currentQuest: Quest? { get set }

    var questCount: Int? { get set }

    var questIds: [Int]? { get set }

    var sectionQuestIds: Set<Int> { get set }

    var errorQuestIds: Set<Int> { get set }

    var rightQuestIds: Set<Int> { get set }

    var isFinished: Bool { get set }

    var isRewarded: Bool { get set }

    var isRewardedSuccess: Bool { get set }

    func isNext() -> Bool

    func next() -> Int?

    func addSectionQuest()

    func addErrorQuest()

    func addRightQuest()
}
