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

class GameProcessTest: XCTestCase {
    
    let testThemeId = 1
    let testSectionId = 1
    let testIsSort = false

    var repo: ContentRepository!
    var userRepo: UserRepository!
    
    var arcade: GameProcessProtocol!
    var marathon: GameProcessProtocol!
    var sprint: GameProcessProtocol!
    var error: GameProcessProtocol!

    override func setUp() {
        repo =  IocContainer.app.resolve()
        userRepo = IocContainer.app.resolve()

        arcade = GameProcess(mode: .arcade)
        marathon = GameProcess(mode: .marathon)
        sprint = GameProcess(mode: .sprint)
        error = GameProcess(mode: .error)
    }

    override func tearDown() {
        repo = nil
        userRepo = nil
        
        arcade = nil
        marathon = nil
        sprint = nil
        error = nil
    }
    
    // MARK: - Variable - GameControlProtocol
    
    // currentQuest
    func testCurrentQuest() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        let _ = initErrors(list: list)
        
        let arcadeQuest = initCurrentQuest(process: arcade)
        let marathonQuest = initCurrentQuest(process: marathon)
        let sprintQuest = initCurrentQuest(process: sprint)
        let errorQuest = initCurrentQuest(process: error)

        XCTAssertEqual(arcade.currentQuest!.id, arcadeQuest.id)
        XCTAssertEqual(marathon.currentQuest!.id, marathonQuest.id)
        XCTAssertEqual(sprint.currentQuest!.id, sprintQuest.id)
        XCTAssertEqual(error.currentQuest!.id, errorQuest.id)

    }
    
    private func initCurrentQuest(process: GameProcessProtocol) -> Quest {
        var tempProcess = process
        let quest = repo.getQuest(id: process.next()!)!
        tempProcess.currentQuest = quest
        return quest
    }
    
    // questCount
    func testQuestCount() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        let errors = initErrors(list: list)
        
        arcade.questCount = list.count
        marathon.questCount = list.count
        sprint.questCount = list.count
        error.questCount = errors.count

        XCTAssertEqual(arcade.questCount, list.count)
        XCTAssertEqual(marathon.questCount, list.count)
        XCTAssertEqual(sprint.questCount, list.count)
        XCTAssertEqual(error.questCount, errors.count)
    }
    
    // questIds
    func testInitQuestIds() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        let errors = initErrors(list: list)
        
        XCTAssertEqual(arcade.questIds, list)
        XCTAssertEqual(marathon.questIds, list)
        XCTAssertEqual(sprint.questIds, list)
        XCTAssertEqual(error.questIds, errors)
    }
    
    private func initQuests(list: [Int]) {
        arcade.questIds = list
        marathon.questIds = list
        sprint.questIds = list
    }
    
    private func initErrors(list: [Int]) -> [Int] {
        let errorsIds = Set(list.filter { $0 < 15 })
        userRepo.updateErrors(errors: errorsIds)
        let errors = userRepo.getErrorIds()!
        error.questIds = errors
        return errors
    }
    
    // MARK: - Variable - GameProgressProtocol
    
    // progress
    func testProgress() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        let errors = initErrors(list: list)
        
        arcade.questCount = list.count
        marathon.questCount = list.count
        sprint.questCount = list.count
        error.questCount = errors.count
        
        let progress = Percent.calculatePercent(value: (list.count / 2), count: list.count)
        
        for _ in 1...(list.count / 2) {
            arcade.incrementQuestProgress()
            marathon.incrementQuestProgress()
            sprint.incrementQuestProgress()
        }
        
        let errorProgress = Percent.calculatePercent(value: (errors.count / 2), count: errors.count)
        for _ in 1...(errors.count / 2) {
            error.incrementQuestProgress()
        }
        
        XCTAssertEqual(arcade.progress, progress)
        XCTAssertEqual(marathon.progress, progress)
        XCTAssertEqual(sprint.progress, progress)
        XCTAssertEqual(error.progress, errorProgress)
    }
    
    // point
    func testPoints() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        let errors = initErrors(list: list)
        
        let point = (list.count / 2)
        for _ in 1...point {
            arcade.incrementPoint()
            marathon.incrementPoint()
            sprint.incrementPoint()
        }
        
        let errorPoint = (errors.count / 2)
        for _ in 1...errorPoint {
            error.incrementPoint()
        }
        
        XCTAssertEqual(arcade.point, point)
        XCTAssertEqual(marathon.point, point)
        XCTAssertEqual(sprint.point, point)
        XCTAssertEqual(error.point, errorPoint)
    }
    
    // MARK: - GameControlProtocol
    
    // isNext
    func testIsNext() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: true)!
        initQuests(list: list)
        _ = initErrors(list: list)
        
        let next = arcade.isNext()
        
        arcade.questIds = nil
        arcade.questCount = nil
        let noValid = arcade.isNext()
        
        arcade.questIds = [Int]()
        arcade.questCount = 0
        let end = arcade.isNext()

        XCTAssertTrue(next)
        XCTAssertFalse(noValid)
        XCTAssertFalse(end)
    }
    
    // addSectionQuest
    func testSectionQuestIds() {
        let list = repo.getQuestIdsBySection(theme: testThemeId, section: testSectionId, isSort: testIsSort)!
        arcade.questIds = list
        
        let rightList = Set(list.prefix(10))
        for _ in rightList {
            arcade.currentQuest = repo.getQuest(id: arcade.next()!)!
            arcade.addSectionQuest()
        }
        
        XCTAssertEqual(arcade.sectionQuestIds, rightList)
    }
    
    // addErrorQuest / addResolveQuest
    func testAddErrorOrResolveQuest() {
        let list = repo.getQuestIdsBySection(theme: testThemeId, section: testSectionId, isSort: testIsSort)!
        arcade.questIds = list
        
        let errors = Set(list.prefix(5))
        for id in errors {
            arcade.currentQuest = repo.getQuest(id: id)!
            arcade.addErrorQuest()
        }
        
        XCTAssertEqual(arcade.errorQuestIds, errors)
    }
    
    // addErrorQuest / addResolveQuest
    func testAddResolveQuest() {
        let list = repo.getQuestIds(theme: testThemeId, isSort: testIsSort)!
        
        let index = (list.count - 5)
        let resolved = Set(list[index...(list.count - 1)])
        
        for id in resolved {
            error.currentQuest = repo.getQuest(id: id)!
            error.addRightQuest()
        }
        
        XCTAssertEqual(error.rightQuestIds, resolved)
    }
}
