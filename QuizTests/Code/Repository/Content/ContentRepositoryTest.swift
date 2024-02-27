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

class ContentRepositoryTest: XCTestCase {
    let testTheme = 2 // def 1
    let testSection = 1 // def 1
    let testIsSort = true
    let defaultSectionSplitValue = 20

    var repo: ContentRepository!
    var proRepo: ContentRepository!

    override func setUp() {
        repo = IocContainer.app.resolve()
        
        let formatter: SpecSymbolFormatter = IocContainer.app.resolve()
        let proDb = ContentDatabase(decoder: IocContainer.app.resolve(),
                                    questFormatter: formatter,
                                    mode: .pro)
        proRepo = ContentRepository(contentDb: proDb)
    }
    
    override func tearDown() {
        repo = nil
        proRepo = nil
    }
    
    // MARK: - Lite / Pro

    func testProContent() {
        let contentMode: ContentMode = IocContainer.app.resolve()
        if contentMode == .pro {
            XCTAssertTrue(true)
            return
        }
        
        let lite = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: false)!.count
        let pro = proRepo.getQuestIds(theme: Theme.defaultThemeId, isSort: false)!.count
        
        let liteX3 = (lite * 3) - 50 // Sociology quiz

        XCTAssertLessThan(lite, pro)
        XCTAssertLessThanOrEqual(liteX3, pro)
    }
    
    // MARK: - ThemeRepositoryProtocol

    func testThemesNonNil() {
        let themes = repo.getThemes()
        XCTAssertNotNil(themes)
    }
    
    func testAllTheme() {
        let theme = repo.getTheme(id: Theme.defaultThemeId)
        XCTAssertNotNil(theme)
    }
    
    func testGetTheme() {
        let theme = repo.getTheme(id: 4)
        XCTAssertNotNil(theme)
    }
    
    func testErrorTheme() {
        let theme = repo.getTheme(id: -1)
        XCTAssertNil(theme)
    }
    
    func testThemeTitle() {
        let theme = repo.getThemeTitle(id: 4)
        XCTAssertNotNil(theme)
    }
    
    func testValidThemeTitle() {
        let theme = repo.getThemeTitle(id: 4)
        XCTAssertGreaterThan(theme!.count, 1)
    }
    
    func testErrorThemeTitle() {
        let theme = repo.getThemeTitle(id: -1)
        XCTAssertNil(theme)
    }
    
    // MARK: - QuestRepositoryProtocol

    func testQuest() {
        let id = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: false)!.first!
        let quest = repo.getQuest(id: id)
        
        XCTAssertNotNil(quest)
        XCTAssertTrue(quest!.isValid())
    }
    
    func testErrorQuest() {
        let quest = repo.getQuest(id: -1)
        
        XCTAssertNil(quest)
    }
    
    func testQuestIdsNoNil() {
        let list = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: false)
        XCTAssertNotNil(list)
        XCTAssertGreaterThan(list!.count, 0)
    }
    
    /**
     * Проверяет велючена ли сортировка, сравнивая уровни последнего и первого элементов
     */
    func testQuestIdsEnbaleSortInAllCateogry() {
        let isEnable = questIdsEnbaleSort(id: Theme.defaultThemeId)
        XCTAssertTrue(isEnable)
    }
    
    func testQuestIdsEnbaleSortInOtherCateogry() {
        let isEnable = questIdsEnbaleSort(id: 3)
        XCTAssertTrue(isEnable)
    }
    
    private func questIdsEnbaleSort(id: Int) -> Bool {
        let sortList = repo.getQuestIds(theme: id, isSort: true)!

        let firstQuest = sortList.first.map {
            repo.getQuest(id: $0)!
        }
        let lastQuest = sortList.last.map {
            repo.getQuest(id: $0)!
        }
        
        let isEnable = firstQuest!.complexity < lastQuest!.complexity
        
        return isEnable
    }
    
    /**
     * Проверяет валидность порядка вопросов, сравнивая уровни сложности
     */
    func testQuestIdsIsSortedInAllCateogry() {
        let isError: Bool = questIdsIsSorted(id: Theme.defaultThemeId, isSort: true)
        XCTAssertFalse(isError, "Sort no valid")
    }
    
    func testQuestIdsIsSortedInOtherCateogry() {
        let isError: Bool = questIdsIsSorted(id: 3, isSort: true)
        XCTAssertFalse(isError, "Sort no valid")
    }
    
    /**
     * Проверяет валидность порядка вопросов, сравнивая уровни сложности
     */
    func testQuestIdsNonSortedInAllCateogry() {
        let isError: Bool = questIdsIsSorted(id: Theme.defaultThemeId, isSort: false)
        XCTAssertTrue(isError, "Sort enable all time")
    }
    
    func testQuestIdsNonSortedInOtherCateogry() {
        let isError: Bool = questIdsIsSorted(id: 3, isSort: false)
        XCTAssertTrue(isError, "Sort enable all time")
    }
    
    private func questIdsIsSorted(id: Int, isSort: Bool) -> Bool {
        let sortList = repo.getQuestIds(theme: id, isSort: isSort)!
        
        var isError: Bool = false
        var currentLevel = 0;
        for i in sortList.indices where i % 3 == 0 {
            let id = sortList[i]
            let quest = repo.getQuest(id: id)!
            //print(i, ", ", quest.complexity)

            if quest.complexity > currentLevel {
                currentLevel = quest.complexity
            } else if quest.complexity < currentLevel {
                isError = true
                break
            }
        }
        
        return isError
    }
    
    func testGetErrors() {
        let quests = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: true)!.filter { $0 < 30 }
        let idSet = Set(quests)
        
        let errors = repo.getErrors(ids: idSet)!
        
        XCTAssertNotNil(errors)
        XCTAssertEqual(idSet.count, errors.count)
    }
    
    func testGetErrorsWithNoValidIds() {
        let ids: Set = [-1]
        let errors = repo.getErrors(ids: ids)
        XCTAssertNil(errors)
    }
    
    // MARK: - SectionRepositoryProtocol
    
    // getSectionCount
    func testSectionCount() {
        let count = repo.getSectionCount(theme: testTheme)!
        
        let questCount = repo.getQuestIds(theme: testTheme, isSort: testIsSort)!.count
        let estimateValue = questCount / defaultSectionSplitValue
        
        XCTAssertEqual(count, estimateValue)
    }
    
    // getQuestIdsBySection
    func testGetQuestIdsBySection() {
        let count = repo.getQuestIdsBySection(theme: testTheme, section: testSection, isSort: testIsSort)!.count
        XCTAssertEqual(count, defaultSectionSplitValue)
        
        let sections = repo.getSections(theme: testTheme)!
        for section in sections {
            let questCount = repo.getQuestIdsBySection(theme: testTheme, section: section.id, isSort: testIsSort)!.count
            
            XCTAssertEqual(questCount, section.count)
        }
    }
    
    //  getSections
    func testGetSections() {
        let theme = repo.getTheme(id: testTheme)!
        let count = repo.getSectionCount(theme: testTheme)!
        let sections = repo.getSections(theme: testTheme)!
        
        var total = 0
        for s in sections {
            total += s.count
        }
        
        XCTAssertEqual(count, sections.count)
        XCTAssertEqual(total, theme.count)
        XCTAssertEqual(count, sections.last!.id)
    }
    
    // MARK: - Support - valid content
    
    func testValidContent() {
        let errors = checkContentData(repo: repo)
        
        if !errors.isEmpty {
            print("Error count: ", errors.count)
            errors.forEach {
                print("Error: ", $0)
            }
        }
        
        XCTAssertEqual(errors.count, 0)
    }
    
    func testProValidContent() {
        let errors = checkContentData(repo: proRepo)
        
        if !errors.isEmpty {
            print("Error count: ", errors.count)
            errors.forEach {
                print("Error: ", $0)
            }
        }
        
        XCTAssertEqual(errors.count, 0)
    }
    
    private func checkContentData(repo: ContentRepository) -> [Quest] {
        let ids = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: testIsSort)!
        
        var errors: [Quest] = []
        for id in ids {
            let quest = repo.getQuest(id: id)!
            
            if !quest.isValid() {
                errors.append(quest)
            }
        }
        
        return errors
    }
    
    let maxAnswerQuota = 30
    func testShuffledAnswers() {
        let quests = repo.getQuestIds(theme: Theme.defaultThemeId, isSort: testIsSort)!
            .map { return /*decoder.decrypt(encryptedQuest: */repo.getQuest(id: $0)!/*)*/ }
        
        let one = getCheckAnswerIndexCount(quests: quests, checkIndex: 0)
        let two = getCheckAnswerIndexCount(quests: quests, checkIndex: 1)
        let three = getCheckAnswerIndexCount(quests: quests, checkIndex: 2)
        let four = getCheckAnswerIndexCount(quests: quests, checkIndex: 3)
        
        let onePercent = Percent.calculatePercent(value: one, count: quests.count)
        let twoPercent = Percent.calculatePercent(value: two, count: quests.count)
        let threePercent = Percent.calculatePercent(value: three, count: quests.count)
        let fourPercent = Percent.calculatePercent(value: four, count: quests.count)
        
        XCTAssertLessThanOrEqual(onePercent, maxAnswerQuota)
        XCTAssertLessThanOrEqual(twoPercent, maxAnswerQuota)
        XCTAssertLessThanOrEqual(threePercent, maxAnswerQuota)
        XCTAssertLessThanOrEqual(fourPercent, maxAnswerQuota)
    }
    
    private func getCheckAnswerIndexCount(quests: [Quest?], checkIndex: Int) -> Int {
        return quests.filter {
            return $0!.answers.firstIndex(of: $0!.trueAnswer) == checkIndex
        }.count
    }
}

