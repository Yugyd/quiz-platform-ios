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

class DataManagerTest: XCTestCase {
    
    let testTheme = 1 // def 1
    let testSection = 1
    let testAddedSection = 2
    let testIsSort = true
    
    var contentRepo: ContentRepository!
    var userRepo: UserRepositoryProtocol!
    
    /**
     * 0 - Arcade, 1 - Marathon, 2 - Sprint, 3 - Error
     */
    var managers: [DataManagerProtocol]!
    let arcadeIndex = 0
    let marathonIndex = 1
    let sprintIndex = 2
    let errorIndex = 3

    override func setUp() {
        contentRepo = IocContainer.app.resolve()
        userRepo = IocContainer.app.resolve()
        _ = userRepo.reset()
        
        managers = []
        managers.insert(DataManager(contentRepository: contentRepo, userRepository: userRepo, mode: .arcade),
                        at: arcadeIndex)
        managers.insert(DataManager(contentRepository: contentRepo, userRepository: userRepo, mode: .marathon),
                        at: marathonIndex)
        managers.insert(DataManager(contentRepository: contentRepo, userRepository: userRepo, mode: .sprint),
                          at: sprintIndex)
        managers.insert(DataManager(contentRepository: contentRepo, userRepository: userRepo, mode: .error),
                          at: errorIndex)
    }

    override func tearDown() {
        contentRepo = nil
        userRepo = nil
        managers = nil
    }
    
    // MARK: - loadQuest
    
    func testLoadQuest() {
        let id = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!.first!
        let quest = managers[arcadeIndex].loadQuest(id: id)!
        XCTAssertEqual(quest.id, id)
    }
    
    // MARK: - loadQuestIds
 
    func testLoadQuestIdsInArcade() {
        let validIds = contentRepo.getQuestIdsBySection(theme: testTheme, section: testTheme, isSort: testIsSort)!
        let isError = checkLoadQuestIds(manager: managers[arcadeIndex], validIds: validIds)
        XCTAssertFalse(isError)
    }
    
    func testLoadQuestIdsInMarathonAndSprint() {
        let validIds = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!
        let isMarathonError = checkLoadQuestIds(manager: managers[marathonIndex], validIds: validIds)
        let isSprintError = checkLoadQuestIds(manager: managers[sprintIndex], validIds: validIds)
        XCTAssertFalse(isMarathonError)
        XCTAssertFalse(isSprintError)
    }
    
    func testLoadQuestIdsInError() {
        let initErrorIds = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!.prefix(10)
        userRepo.updateErrors(errors: Set(initErrorIds))
        
        let validIds = userRepo.getErrorIds()!
        let isError = checkLoadQuestIds(manager: managers[errorIndex], validIds: validIds)
        XCTAssertFalse(isError)
    }
    
    private func checkLoadQuestIds(manager: DataManagerProtocol!, validIds: [Int]) -> Bool{
        let ids = manager.loadQuestIds(theme: testTheme, section: testTheme, isSort: testIsSort)!
        
        let isError = ids.filter {
            !(validIds.contains($0))
        }.count > 1
        
        return isError
    }
    
    // MARK: - saveSectionData
    
    func testModeInvariantSaveSectionData() {
        let rightIds = getRightSections()
        let marathonResult = managers[marathonIndex].saveSectionData(theme: testTheme, section: testSection, sectionQuestIds: rightIds)
        let sprintResult = managers[sprintIndex].saveSectionData(theme: testTheme, section: testSection, sectionQuestIds: rightIds)
        let errorResult = managers[errorIndex].saveSectionData(theme: testTheme, section: testSection, sectionQuestIds: rightIds)
        
        XCTAssertEqual(marathonResult, 0)
        XCTAssertEqual(sprintResult, 0)
        XCTAssertEqual(errorResult, 0)
    }
    
    private func getRightSections() -> Set<Int> {
        let manager = managers[arcadeIndex]
        let ids = manager.loadQuestIds(theme: testTheme, section: testSection, isSort: testIsSort)!
        let rightIds = Set(ids.prefix(9))
        return rightIds
    }
    
    func testSaveSectionData() {
        let resetIds = contentRepo.getQuestIds(theme: testSection, isSort: testIsSort)!
        _ = userRepo.resetThemeProgress(theme: testTheme)
        _ = userRepo.resetSectionProgress(questIds: resetIds)
        
        let manager = managers[arcadeIndex]
        let ids = manager.loadQuestIds(theme: testTheme, section: testSection, isSort: testIsSort)!
        let rightIds = Set(ids.prefix(9))
        let point = saveSectionRecord(manager: manager, rightIds: rightIds)
        XCTAssertEqual(point, rightIds.count)
        XCTAssertEqual(getSectionRecord(), rightIds.count)
        XCTAssertEqual(getRecord().arcade, rightIds.count)
        
        let oldSectionRecord = getSectionRecord()
        let oldArcadeRecord = getRecord().arcade
        let newRightIds = ids.filter { !(rightIds.contains($0)) }
        let newPoint = saveSectionRecord(manager: manager, rightIds: Set(newRightIds))
        XCTAssertEqual(newPoint, newRightIds.count)
        XCTAssertEqual(getSectionRecord(), newRightIds.count)
        XCTAssertNotEqual(oldSectionRecord, getSectionRecord())
        XCTAssertNotEqual(oldArcadeRecord, getRecord().arcade)
    }
    
    private func saveSectionRecord(manager: DataManagerProtocol!, rightIds: Set<Int>) -> Int {
        let count = manager.saveSectionData(theme: testTheme, section: testSection, sectionQuestIds: rightIds)
        manager.saveRecord(theme: testTheme, point: count, time: 999)
        return count
    }
    
    private func getRecord() -> Point {
        var theme = contentRepo.getTheme(id: testTheme)!
        theme = userRepo.attachPoints(themes: [theme]).first!
        return theme.point
    }
    
    private func getSectionRecord() -> Int {
        var section: Section = contentRepo.getSections(theme: testTheme)!.first {
            $0.id == testSection
            }!
        section = userRepo.attachPoints(sections: [section]).first!
        return section.point!
    }
    
    func testAddedSectionRecord() {
        let m = managers[arcadeIndex]

        let sections = contentRepo.getSections(theme: testTheme)!
        if sections.count < 2 {
            fatalError("Set new theme, section not min count")
        }
        
        let testCount = 19
        let oneIds = Set(sections[0].questIds!.prefix(testCount))
        let twoIds = Set(sections[1].questIds!.prefix(testCount))
        let onePoint = m.saveSectionData(theme: testTheme, section: sections[0].id, sectionQuestIds: oneIds)
        m.saveRecord(theme: testTheme, point: onePoint, time: 999)

        let twoPoint = m.saveSectionData(theme: testTheme, section: sections[1].id, sectionQuestIds: twoIds)
        m.saveRecord(theme: testTheme, point: twoPoint, time: 999)
        
        let newRecord = getRecord().arcade
        
        XCTAssertEqual(twoPoint, (testCount * 2))
        XCTAssertEqual(newRecord, twoPoint)
    }
    
    // saveRecord
    func testSaveRecord() {
        let testPoint = 99
        for m in managers {
            m.saveRecord(theme: testTheme, point: testPoint, time: 999)
        }
        let point = getRecord()
        let errorPoint = userRepo.getErrorIds()?.count ?? 0
        
        XCTAssertEqual(point.arcade, testPoint)
        XCTAssertEqual(point.marathon, testPoint)
        XCTAssertEqual(point.sprint, testPoint)
        XCTAssertNotEqual(errorPoint, testPoint)
    }
    
    // saveErrorData
    func testSaveErrorDataInErrorMode() {
        let errorIds = Set(contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!.prefix(9))
        let resolveIds = Set(errorIds.prefix(3))
        
        userRepo.updateErrors(errors: errorIds)
        
        managers[errorIndex].saveErrorData(errorQuestIds: errorIds, rightQuestIds: nil)
        let errorCount = userRepo.getErrorIds()!.count
        managers[errorIndex].saveErrorData(errorQuestIds: nil, rightQuestIds: resolveIds)
        let resolveCount = userRepo.getErrorIds()!.count

        XCTAssertEqual(errorCount, errorIds.count)
        XCTAssertEqual(resolveCount, (errorIds.count - resolveIds.count))
    }
    
    func testSaveErrorDataInNonErrorMode() {
        var ids = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!
        let tempErrorIds = Set(ids.prefix(9))
        userRepo.updateErrors(errors: tempErrorIds)
        
        for m in managers {
            if m === managers[errorIndex] { continue }
            
            let currentErrorsIds = userRepo.getErrorIds()!
            
            let resolveIds = Set(currentErrorsIds.prefix(2))
            let oldResolveCount = userRepo.getErrorIds()!.count
            m.saveErrorData(errorQuestIds: nil, rightQuestIds: resolveIds)
            let resolveCount = userRepo.getErrorIds()!.count

            let testCount = 9
            ids.removeAll {
                tempErrorIds.contains($0) || currentErrorsIds.contains($0)
            }
            let newErrorsIds = Set(ids.prefix(testCount))
            let oldErrorCount = userRepo.getErrorIds()!.count
            m.saveErrorData(errorQuestIds: newErrorsIds, rightQuestIds: nil)
            let errorCount = userRepo.getErrorIds()!.count
            
            XCTAssertEqual(resolveCount, oldResolveCount)
            XCTAssertEqual(errorCount, (oldErrorCount + testCount))
        }
    }
    
    // Save Section Data - Time Size
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
