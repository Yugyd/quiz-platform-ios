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
  * Contains all application logic and game data. Submits to Presenter, knows nothing about him.
  */
final class GameProcess: GameProcessProtocol {

    static let lifeCondition = 2
    static let timeCondition = 60

    enum ConditionType {
        case life
        case time
    }

    var gameMode: Mode
    var currentQuest: Quest?
    var questCount: Int?

    /**
     * Shuffled array.
     */
    var questIds: [Int]?

    var sectionQuestIds: Set<Int>
    var errorQuestIds: Set<Int>
    var rightQuestIds: Set<Int>

    var progress: Int {
        get {
            if let count = questCount {
                return Percent.calculatePercent(value: game.questProgress, count: count)
            } else {
                return 0 // errorProgressStub
            }
        }
    }

    var point: Int {
        get {
            return game.point
        }
    }

    var condition: Int {
        get {
            return game.condition
        }
    }

    var isFinished: Bool = false
    var isRewarded: Bool = false
    var isRewardedSuccess = false

    private let game: Game
    private var delegate: GameProcessDelegate

    init(mode: Mode, delegate: GameProcessDelegate) {
        self.gameMode = mode
        self.delegate = delegate
        self.game = Game(condition: delegate.initCondition())
        self.sectionQuestIds = Set()
        self.errorQuestIds = Set()
        self.rightQuestIds = Set()
    }

    convenience init(mode: Mode) {
        switch mode {
        case .arcade, .marathon, .error, .aiTasks:
            self.init(mode: mode, delegate: ContinueGameProcessDelegate())
        case .sprint:
            self.init(mode: mode, delegate: SprintGameProcessDelegate())
        case .unused:
            fatalError("No init game mode")
        }
    }

    // MARK: - GameControlProtocol

    func isNext() -> Bool {
        return !(questIds?.isEmpty ?? true)
    }

    func next() -> Int? {
        let id = questIds?.first
        questIds?.removeFirst()
        return id
    }

    func addSectionQuest() {
        guard let id = currentQuest?.id, gameMode == .arcade else {
            return
        }
        sectionQuestIds.insert(id)
    }

    func addErrorQuest() {
        guard let id = currentQuest?.id else {
            return
        }
        errorQuestIds.insert(id)
    }

    func addRightQuest() {
        guard let id = currentQuest?.id, gameMode == .error else {
            return
        }
        rightQuestIds.insert(id)
    }

    // MARK: - GameProgressProtocol

    func incrementQuestProgress() {
        game.questProgress += 1
    }

    func decrementQuestProgress() {
        game.questProgress -= 1
    }

    func incrementPoint() {
        game.point += 1
    }

    // MARK: - GameDataProtocol

    func isValidCondition() -> Bool {
        return delegate.isValidCondition(gameData: game)
    }

    func decrementCondition() {
        delegate.decrementCondition(gameData: game)
    }

    func specDecrementCondition() {
        delegate.specDecrementCondition(gameData: game)
    }

    func addExtraCondition() {
        delegate.addExtraCondition(gameData: game)
    }

    func getConditionType() -> GameProcess.ConditionType {
        delegate.getConditionType()
    }
}
