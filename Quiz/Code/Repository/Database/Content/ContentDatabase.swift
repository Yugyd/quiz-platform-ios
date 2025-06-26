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

import SQLite

class ContentDatabase: ContentDatabaseProtocol {
    
    private static let dbFileName = "content-encode.db"
    private let loggerTag = "ContentDatabase"
    
    private var newVersion: Int
    private let logger: Logger
    private let path: String
    private var connection: Connection?
    private var isInitializing: Bool = false

    private let decoder: DecoderProtocol
    private let questFormatter: SymbolFormatter
    
    init(
        decoder: DecoderProtocol,
        questFormatter: SymbolFormatter,
        version: Int,
        logger: Logger
    ) {
        self.decoder = decoder
        self.questFormatter = questFormatter
        
        self.logger = logger
        self.newVersion = version
        self.path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first! + "/\(ContentDatabase.dbFileName)"
    }
    
    // MARK: - SqliteDatabaseProtocol

    private func getReadableConnection() throws -> Connection? {
        return try getWritableConnection()
    }
    
    private func getWritableConnection() throws-> Connection? {
        if connection != nil {
            return connection
        }
        
        if isInitializing {
            fatalError("getWritableConnection called recursively")
        }
        
        do {
            defer {
                isInitializing = false
            }
            
            isInitializing = true
            connection = try Connection(path)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot connect to Database. Error is:")
            connection = nil
        }
        
        if let connection = connection {
            let version = connection.userVersion
            
            if version == 0 {
                onCreate(db: connection)
            } else {
                if version < newVersion {
                    onUpgrade(db: connection, oldVersion: Int(version), newVersion: newVersion)
                }
            }
            
            connection.userVersion = Int32(newVersion)
        }
        
        return connection
    }
    
    private func onCreate(db: Connection) {
        do {
            try db.run(ThemeContract.themeTable.create(ifNotExists: true) { t in
                t.column(ThemeContract.id, primaryKey: .default)
                t.column(ThemeContract.ordinal)
                t.column(ThemeContract.name)
                t.column(ThemeContract.info)
                t.column(ThemeContract.image)
                t.column(ThemeContract.count)
            })
            
            try db.run(QuestContract.questTable.create(ifNotExists: true) { t in
                t.column(QuestContract.id, primaryKey: .default)
                t.column(QuestContract.quest)
                t.column(QuestContract.true_answer)
                t.column(QuestContract.answer2)
                t.column(QuestContract.answer3)
                t.column(QuestContract.answer4)
                t.column(QuestContract.answer5)
                t.column(QuestContract.answer6)
                t.column(QuestContract.answer7)
                t.column(QuestContract.answer8)
                t.column(QuestContract.complexity)
                t.column(QuestContract.category)
                t.column(QuestContract.section)
            })
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot create table to Database. Error is:")
        }
    }
    
    private func onUpgrade(db: Connection, oldVersion: Int?, newVersion: Int?) {
        
    }
    
    // MARK: - ThemeRepositoryProtocol
    
    /**
     * Returns a list with all categories (objects). Gets a cursor sorted in order (special identifier).
     */
    func getThemes() async throws -> [Theme]? {
        return try await Task.detached(priority: .background) { [self] () -> [Theme]? in
            guard let db = try getReadableConnection() else {
                return nil
            }
            
            do {
                let query = ThemeContract.themeTable.order(ThemeContract.ordinal.asc)
                let result = Array(try db.prepare(query))
                return result.map { row in
                    let point = Point(count: row[ThemeContract.count], arcade: 0, marathon: 0, sprint: 0)
                    return Theme(
                        id: row[ThemeContract.id],
                        name: row[ThemeContract.name],
                        info: row[ThemeContract.info],
                        image: row[ThemeContract.image],
                        count: row[ThemeContract.count],
                        ordinal: row[ThemeContract.ordinal],
                        point: point
                    )
                }
            } catch {
                CrashlyticsUtils.record(root: error, isPrint: true)
                return nil
            }
        }.value
    }
    
    func addThemes(themes: [Theme]?) async throws {
        try await Task.detached(priority: .background) {
            guard let db = try self.getWritableConnection() else {
                return
            }
            
            if themes == nil {
                return
            }
            
            do {
                try db.transaction {
                    for theme in themes! {
                        let query = ThemeContract.themeTable
                            .insert(
                                or:.replace,
                                ThemeContract.id <- theme.id,
                                ThemeContract.ordinal <- theme.ordinal,
                                ThemeContract.name <- theme.name,
                                ThemeContract.info <- theme.info,
                                ThemeContract.image <- theme.image,
                                ThemeContract.count <- theme.count
                            )
                        
                        try db.run(query)
                    }
                }
            } catch {
                CrashlyticsUtils.record(
                    root: error,
                    isPrint: true,
                    startMsg: "Cannot fill table to Database. Error is:"
                )
            }
        }.value
    }
    
    /**
     * Returns a category object based on the given id
     * @param id category id
     */
    func getTheme(id: Int) async throws -> Theme? {
        return try await Task.detached(priority: .background) { [self] () -> Theme? in
            guard let db = try getReadableConnection() else {
                return nil
            }
            
            do {
                let query = ThemeContract.themeTable.filter(ThemeContract.id == id)
                let result = try db.pluck(query)
                return result.map { row in
                    let point = Point(count: row[ThemeContract.count], arcade: 0, marathon: 0, sprint: 0)
                    return Theme(
                        id: row[ThemeContract.id],
                        name: row[ThemeContract.name],
                        info: row[ThemeContract.info],
                        image: row[ThemeContract.image],
                        count: row[ThemeContract.count],
                        ordinal: row[ThemeContract.ordinal],
                        point: point
                    )
                }
            } catch {
                CrashlyticsUtils.record(root: error, userInfo: ["id": "\(id)"])
                return nil
            }
        }.value
    }
    
    func getThemeTitle(id: Int) async throws -> String? {
        return try await Task.detached(priority: .background) { [self] () -> String? in
            guard let db = try getReadableConnection() else {
                return nil
            }
            
            do {
                let query = ThemeContract.themeTable
                    .select(ThemeContract.name)
                    .filter(ThemeContract.id == id)
                let result = try db.pluck(query)
                return result.map { row in
                    row[ThemeContract.name]
                }
            } catch {
                CrashlyticsUtils.record(root: error, userInfo: ["id": "\(id)"])
                return nil
            }
        }.value
    }
    
    // MARK: - QuestRepositoryProtocol
    
    /**
     * Initializes and returns a question object by inidi factor
     * @param id question identifier
     */
    func getQuest(id: Int) async throws -> Quest? {
        return try await Task.detached(priority: .background) { [self] () -> Quest? in
            guard let db = try getReadableConnection() else {
                return nil
            }
            
            do {
                let query = QuestContract.questTable.filter(QuestContract.id == id)
                let result = try db.pluck(query)
                
                return result.map { row in
                    var answers: [String] =
                    ([row[QuestContract.answer2],
                      row[QuestContract.answer3],
                      row[QuestContract.answer4],
                      row[QuestContract.answer5],
                      row[QuestContract.answer6],
                      row[QuestContract.answer7],
                      row[QuestContract.answer8]].filter { answer in
                        answer != nil
                    } as! [String])
                    .shuffled()
                    .prefix(3)
                    .map {
                        return $0
                    }
                    answers.append(row[QuestContract.true_answer])
                    let shuffledAnsweers: [String] = answers.shuffled()
                    
                    let decryptQuest = decoder.decrypt(encryptedText: row[QuestContract.quest])
                    let decryptTrueAnswer = decoder.decrypt(encryptedText: row[QuestContract.true_answer])
                    let decryptAnswers = shuffledAnsweers.map { answer in
                        decoder.decrypt(encryptedText: answer)
                    }
                    
                    return Quest(
                        id: Int(row[QuestContract.id]),
                        quest: questFormatter.format(data: decryptQuest),
                        trueAnswer: decryptTrueAnswer,
                        answers: decryptAnswers,
                        complexity: row[QuestContract.complexity],
                        category: row[QuestContract.category],
                        section: row[QuestContract.section]
                    )
                }
            } catch {
                CrashlyticsUtils.record(root: error, userInfo: ["id": "\(id)"])
                return nil
            }
        }.value
    }
    
    func addQuests(quests: [Quest]?) async throws {
        try await Task.detached(priority: .background) {
            guard let db = try self.getWritableConnection() else {
                return
            }
            
            if quests == nil {
                return
            }
            
            do {
                try db.transaction {
                    for quest in quests! {
                        let query = QuestContract.questTable
                            .insert(
                                or:.replace,
                                QuestContract.id <- quest.id,
                                QuestContract.quest <- quest.quest,
                                QuestContract.true_answer <- quest.trueAnswer,
                                QuestContract.answer2 <- quest.answers[1],
                                QuestContract.answer3 <- quest.answers[2],
                                QuestContract.answer4 <- quest.answers[3],
                                QuestContract.complexity <- quest.complexity,
                                QuestContract.category <- quest.category,
                                QuestContract.section <- quest.section
                            )
                        
                        try db.run(query)
                    }
                }
            } catch {
                CrashlyticsUtils.record(
                    root: error,
                    isPrint: true,
                    startMsg: "Cannot fill table to Database. Error is:"
                )
            }
        }.value
    }
    
    /**
     * Returns all question IDs, by given category, difficulty level, and also sorts by
     * level of complexity, if required, depending on the value of the variable.
     */
    func getQuestIds(theme: Int, isSort: Bool) async throws -> [Int]? {
        return try await Task.detached(priority: .background) { [self] () -> [Int]? in
            let query: Table
            if theme == Theme.defaultThemeId {
                query = QuestContract.questTable.select(QuestContract.id, QuestContract.complexity)
            } else {
                query = QuestContract.questTable
                    .select(QuestContract.id, QuestContract.complexity)
                    .filter(QuestContract.category == theme)
            }
            
            return try await getQuestIdsByQuery(query: query, isSort: isSort)
        }.value
    }
    
    func getErrors(ids: Set<Int>) async throws -> [ErrorQuest]? {
        return try await Task.detached(priority: .background) { [self] () -> [ErrorQuest]? in
            guard let db = try getReadableConnection() else {
                return nil
            }
            
            do {
                let query = QuestContract.questTable.filter(ids.contains(QuestContract.id))
                let result = Array(try db.prepare(query))
                
                if result.isEmpty {
                    return nil
                } else {
                    return result.map { row in
                        let decryptQuest = decoder.decrypt(encryptedText: row[QuestContract.quest])
                        let quest = questFormatter.format(data: decryptQuest)
                        let trueAnswer = decoder.decrypt(encryptedText: row[QuestContract.true_answer])
                        
                        return ErrorQuest(id: row[QuestContract.id],
                                          quest: quest,
                                          trueAnswer: trueAnswer)
                    }
                }
            } catch {
                CrashlyticsUtils.record(root: error, userInfo: ["errorsIds": "\(ids)"])
                return nil
            }
        }.value
    }
    
    // MARK: - SectionRepositoryProtocol
    
    /**
     * Determines the number of sections in the topic. 1. Launch the sections screen.
     * 2. Displaying sections (for initialization).
     */
    func getSectionCount(theme: Int) async throws -> Int? {
        return try await Task.detached(priority: .background) { [self] () -> Int? in
            guard let db = try getReadableConnection() else {
                return 0
            }
            guard theme != Theme.defaultThemeId else {
                return nil
            }
            
            do {
                let query = QuestContract.questTable.filter(QuestContract.category == theme)
                let max = try db.scalar(query.select(QuestContract.section.max)) // -> Int64?
                return max
            } catch {
                CrashlyticsUtils.record(root: error, userInfo: ["theme": "\(theme)"])
                return 0
            }
        }.value
    }
    
    /**
     * Gets a list of section question IDs. There can't be a common section, otherwise everything will get mixed up.
     * Used in the game when receiving a list of questions.
     */
    func getQuestIdsBySection(theme: Int, section: Int, isSort: Bool) async throws -> [Int]? {
        return try await Task.detached(priority: .background) { [self] () -> [Int]? in
            guard theme != Theme.defaultThemeId else {
                return nil
            }
            
            let query = QuestContract.questTable
                .select(QuestContract.id, QuestContract.complexity)
                .filter(QuestContract.category == theme && QuestContract.section == section)
            return try await getQuestIdsByQuery(query: query, isSort: isSort)
        }.value
    }
    
    func getSections(theme: Int) async throws -> [Section]? {
        return try await Task.detached(priority: .background) { [self] () -> [Section]? in
            guard theme != Theme.defaultThemeId else {
                return nil
            }
            guard let count = try await getSectionCount(theme: theme), count != 0 else {
                return nil
            }
            
            var result: [Section] = [Section]()
            for sectionId in 1...count {
                let questIds = try await getQuestIdsBySection(theme: theme, section: sectionId, isSort: false)
                let questCount = questIds?.count ?? 0
                let section = Section(id: sectionId, count: questCount, questIds: questIds, point: nil)
                result.append(section)
            }
            return result
        }.value
    }
    
    // MARK: - ContentResetRepositoryProtocol
    
    func reset() async throws {
        return try await Task.detached(priority: .background) {
            let categoryCount = try await self.resetCategory()
            let questCount = try await self.resetQuest()
            
            self.logger.print(
                tag: self.loggerTag,
                message: "Reset \(categoryCount) categories and \(questCount) quests"
            )
        }.value
    }
    
    // MARK: - Private Data
    
    private func getQuestIdsByQuery(query: Table, isSort: Bool) async throws -> [Int]? {
        guard let db = try getReadableConnection() else {
            return nil
        }
        
        do {
            let result = Array(try db.prepare(query))
            
            let questIdsWithLevels: [(id: Int, complexity: Int)] = result.map { row in
                (row[QuestContract.id], row[QuestContract.complexity])
            }
            
            if isSort {
                return questIdsWithLevels
                    .shuffled()
                    .sorted(by: { one, two in one.complexity < two.complexity })
                    .map({ $0.id })
            } else {
                return questIdsWithLevels.map({ $0.id }).shuffled()
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return nil
        }
    }
    
    private func resetCategory() async throws -> Int {
        guard let db = try getWritableConnection() else {
            return 0
        }
        
        let deleteQuery = ThemeContract.themeTable.delete()
        
        do {
            let changes = try db.run(deleteQuery)
            return Int(changes)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return 0
        }
    }
    
    private func resetQuest() async throws -> Int {
        guard let db = try getWritableConnection() else {
            return 0
        }
        
        let deleteQuery = QuestContract.questTable.delete()
        
        do {
            let changes = try db.run(deleteQuery)
            return Int(changes)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return 0
        }
    }
}
