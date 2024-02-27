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

import SQLite
@testable import Quiz

class TestUserRepository {
    
    let dbProtocol: UserDatabaseProtocol!
    let userDatabase: UserDatabase!
    
    init() {
        dbProtocol = IocContainer.app.resolve()
        userDatabase = self.dbProtocol as? UserDatabase
    }
    
    func getRecord(modeId: Int, themeId: Int) -> [Record]? {
        let connection = userDatabase.getWritableConnection()!

        let query = RecordContract.table
            .filter(RecordContract.modeId == modeId && RecordContract.themeId == themeId)
        
        let records = Array(try! connection.prepare(query)).map { row in
            Record(id: row[RecordContract.id],
                   themeId: row[RecordContract.themeId],
                   modeId: row[RecordContract.modeId],
                   record: row[RecordContract.record],
                   totalTime: row[RecordContract.total_time])
        }
        
        if records.isEmpty {
            return nil
        } else {
            return records
        }
    }
}

class UserRepositoryTest: XCTestCase {
    
    let testTheme = 2 // def 1
    let testSection = 1 // def 1
    let testIsSort = true
    
    var repo: UserRepository!
    var testUserRepo: TestUserRepository!
    
    var contentRepo: ContentRepository!
    var allTheme: Theme!
    var theme: Theme!
    var themes: [Theme]!
    
    override func setUp() {
        repo = IocContainer.app.resolve()
        let _ = repo.reset()
        
        testUserRepo = TestUserRepository()
        
        contentRepo = IocContainer.app.resolve()
        allTheme = contentRepo.getTheme(id: Theme.defaultThemeId)
        theme = contentRepo.getTheme(id: 1) // use testTheme
        themes = [allTheme, theme]
    }

    override func tearDown() {
        //repo.reset()
        repo = nil
        testUserRepo = nil
        contentRepo = nil
        themes = nil
        allTheme = nil
        theme = nil
    }

    //    MARK: - RecordRepositoryProtocol
    
    // addRecord
    func testAddRecordInArcade() {
        repo.addRecord(mode: .arcade, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .arcade, theme: theme.id, value: 99, time: 999)
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertEqual(themes[0].point.arcade, 99) // add mode key
        XCTAssertEqual(themes[1].point.arcade, 99)
    }

    func testAddRecordInMarathon() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 99, time: 999)
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertEqual(themes[0].point.marathon, 99) // add mode key
        XCTAssertEqual(themes[1].point.marathon, 99)
    }
    
    func testAddRecordInSprint() {
        repo.addRecord(mode: .sprint, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .sprint, theme: theme.id, value: 99, time: 999)
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertEqual(themes[0].point.sprint, 99) // add mode key
        XCTAssertEqual(themes[1].point.sprint, 99)
    }
    
    func testAddRecordNoSupportErrorMode() {
        repo.addRecord(mode: .error, theme: allTheme.id, value: 99, time: 999)
        let result = testUserRepo.getRecord(modeId: DatabaseMode(mode: .error).id, themeId: allTheme.id)
        XCTAssertNil(result)
    }
    
    func testAddRecordUpdateTime() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 99, time: 999)
        
        let oldTimeAllTheme = testUserRepo.getRecord(modeId: DatabaseMode(mode: .marathon).id, themeId: allTheme.id)![0].totalTime
        let oldTime = testUserRepo.getRecord(modeId: DatabaseMode(mode: .marathon).id, themeId: theme.id)![0].totalTime
                
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 99, time: 999)
        
        let timeAllTheme = testUserRepo.getRecord(modeId: DatabaseMode(mode: .marathon).id, themeId: allTheme.id)![0].totalTime
        let time = testUserRepo.getRecord(modeId: DatabaseMode(mode: .marathon).id, themeId: theme.id)![0].totalTime
        
        let resultAllTheme = timeAllTheme - oldTimeAllTheme
        let result = time - oldTime

        XCTAssertEqual(resultAllTheme, 999)
        XCTAssertEqual(result, 999)
    }
    
    func testAddRecordUpdateInsert() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 999, time: 999)
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertEqual(themes[0].point.marathon, 99)
    }
    
    func testAddRecordNoDoubleInsert() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 999, time: 999)
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        
        let results = testUserRepo.getRecord(modeId: DatabaseMode(mode: .marathon).id, themeId: allTheme.id)!
        
        XCTAssertEqual(results.count, 1)
    }
    
    //    MARK: - PointRepositoryProtocol
    
    // attachPoints
    func testAttachPoints() {
        repo.addRecord(mode: .arcade, theme: allTheme.id, value: 9, time: 999)
        repo.addRecord(mode: .arcade, theme: theme.id, value: 9, time: 999)

        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 9, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 9, time: 999)

        repo.addRecord(mode: .sprint, theme: allTheme.id, value: 9, time: 999)
        repo.addRecord(mode: .sprint, theme: theme.id, value: 9, time: 999)

        themes = repo.attachPoints(themes: themes)
        
        let allPoint = themes[0].point
        let point = themes[1].point

        XCTAssertEqual(allPoint.arcade, 9)
        XCTAssertEqual(allPoint.marathon, 9)
        XCTAssertEqual(allPoint.sprint, 9)
        
        XCTAssertEqual(point.arcade, 9)
        XCTAssertEqual(point.marathon, 9)
        XCTAssertEqual(point.sprint, 9)
    }
    
    func testAttachPointsIsEmptyThemes() {
        var list = [Theme]()
        list = repo.attachPoints(themes: list)
        XCTAssertTrue(list.isEmpty)
    }
    
    func testAttachPointsCountEquals() {
        repo.addRecord(mode: .arcade, theme: allTheme.id, value: 9, time: 999)
        themes = repo.attachPoints(themes: themes)
        XCTAssertEqual(themes[0].count, themes[0].point.count)
    }
    
    //    MARK: - ErrorRepositoryProtocol
    
    // getErrorIds
    func testGetErrorIds() {
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        let count = repo.getErrorIds()!.count
        
        XCTAssertEqual(count, quests.count)
    }
    
    // isHaveErrors
    func testIsHaveErrors() {
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        let result = repo.isHaveErrors()
        
        XCTAssertTrue(result)
    }
    
    // updateErrors
    func testUpdateErrors() {
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        let count = repo.getErrorIds()!.count
        XCTAssertEqual(count, quests.count)
    }
    
    func testUpdateErrorsNotDouble() {
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        repo.updateErrors(errors: quests)

        let count = repo.getErrorIds()!.count
        
        XCTAssertEqual(count, quests.count)
    }
    
    // resolveErrors
    func testResolveErrors() {
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        let notResolveCount = repo.getErrorIds()!.count
        
        let deleteQuests = quests.filter { $0 < 15 }
        repo.resolveErrors(resolved: deleteQuests)
        let deleteCount = deleteQuests.count
        
        let validCount = notResolveCount - deleteCount
        let resultCount = repo.getErrorIds()!.count

        XCTAssertEqual(resultCount, validCount)
    }
    
    //    MARK: - ResetRepositoryProtocol
    
    // resetThemeProgress
    func testResetThemeProgress() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 99, time: 999)
        
        let isAllResult = repo.resetThemeProgress(theme: allTheme.id)
        let isResult = repo.resetThemeProgress(theme: theme.id)
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertTrue(themes[0].point.isEmpty())
        XCTAssertTrue(themes[1].point.isEmpty())
        
        XCTAssertTrue(isAllResult)
        XCTAssertTrue(isResult)
    }
    
    // resetSectionProgress
    func testResetSectionProgress() {
        let ids = contentRepo.getQuestIdsBySection(theme: testTheme, section: testSection, isSort: testIsSort)!
        repo.updateSectionProgress(questIds: Set(ids))
        
        let record = getTestSection().point!
        XCTAssertEqual(record, ids.count)
        
        let isReset = repo.resetSectionProgress(questIds: ids)
        let resetRecord = getTestSection().point
        XCTAssertTrue(isReset)
        XCTAssertNil(resetRecord)
    }
    
    private func getTestSection() -> Section {
        var section = contentRepo.getSections(theme: testTheme)!.first {
            $0.id == testSection
        }!
        section = repo.attachPoints(sections: [section]).first!
        return section
    }
    
    // reset
    func testReset() {
        repo.addRecord(mode: .marathon, theme: allTheme.id, value: 99, time: 999)
        repo.addRecord(mode: .marathon, theme: theme.id, value: 99, time: 999)
        let quests = Set(contentRepo.getQuestIds(theme: allTheme.id, isSort: false)!.filter { $0 < 30 })
        repo.updateErrors(errors: quests)
        
        let _ = repo.reset()
        
        themes = repo.attachPoints(themes: themes)
        
        XCTAssertFalse(repo.isHaveErrors())
        XCTAssertTrue(themes[0].point.isEmpty())
        XCTAssertTrue(themes[1].point.isEmpty())
    }
    
    // MARK: - SectionRepositoryProtocol

    // attachPoints / updateSectionProgress
    func testSectionAttachPointsAndUpdateSectionProgress() {
        var sections = contentRepo.getSections(theme: testTheme)!
        let quests = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!
        repo.updateSectionProgress(questIds: Set(quests))
        sections = repo.attachPoints(sections: sections)
        
        var total = 0
        for s in sections {
            total += s.point!
        }
        
        XCTAssertEqual(total, quests.count)
    }
    
    // getTotalProgressSections
    func testGetTotalProgressSections() {
        let quests = contentRepo.getQuestIds(theme: testTheme, isSort: testIsSort)!
    
        let testCount = 20
        let progresIds = quests.prefix(testCount)
        repo.updateSectionProgress(questIds: Set(progresIds))
        
        let result = repo.getTotalProgressSections(questIds: quests)
        
        XCTAssertEqual(result, testCount)
    }
}
