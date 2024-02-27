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

class SprintGameProcessDelegate: GameProcessDelegate {

    static let specErrorFine = 5

    let conditionValueMin = 0

    func initCondition() -> Int {
        return GameProcess.timeCondition
    }

    func isValidCondition(gameData: Game) -> Bool {
        return gameData.condition > conditionValueMin
    }

    func decrementCondition(gameData: Game) {
        gameData.condition -= 1
    }

    func specDecrementCondition(gameData: Game) {
        let result = gameData.condition - SprintGameProcessDelegate.specErrorFine

        if result < 0 {
            gameData.condition = 0
        } else {
            gameData.condition = result
        }
    }

    func addExtraCondition(gameData: Game) {
        fatalError("Sprint mode non supported extra condition")
    }

    func getConditionType() -> GameProcess.ConditionType {
        return .time
    }
}
