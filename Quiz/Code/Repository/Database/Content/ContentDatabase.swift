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

    private static let dbFileExtension = "db"

    private var version: Int = 0
    private let dbFileName: String
    private let forcedUpgradeVersion: Int
    private let path: String

    private var connection: Connection?
    private var isInitializing: Bool = false

    private let decoder: DecoderProtocol
    private let questFormatter: SymbolFormatter

    init(decoder: DecoderProtocol, questFormatter: SymbolFormatter, mode: ContentMode) {
        self.decoder = decoder
        self.questFormatter = questFormatter

        self.dbFileName = mode.dbFileName
        self.forcedUpgradeVersion = mode.dbVersion

        let dictionaryPath = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
        ).first!
        self.path = dictionaryPath + "/" + dbFileName + "." + ContentDatabase.dbFileExtension
    }

    // MARK: - ContentDatabaseProtocol

    /**
     * Create and/or open a database that will be used for reading and writing.
      * On the first call, the database will be extracted and copied from the application resources folder.
      *
      * <p>After a successful opening, the database is cached so you can call
      * this method every time you need to write to the database.
      * (Be sure to call {@link #close} when you no longer need the database.)
      * Errors such as incorrect permissions or full disk may cause this method to fail,
      * but future attempts may be successful if the problem is resolved.
      *
      * Updating the database may take a long time, you
      * should not call this method from the main application thread, including
      * from {@link android.content.ContentProvider#onCreate ContentProvider.onCreate()}.
      *
      * @throws SQLiteException if the database cannot be opened for writing
      * @return the read/write database object is valid until {@link #close} is called
     */
    func getReadableConnection() -> Connection? {
        if connection != nil {
            return connection // The database is already open for action
        }

        if isInitializing {
            fatalError("getReadableConnection вызывается рекурсивно")
        }

        do {
            defer {
                isInitializing = false
            }

            isInitializing = true
            connection = createOrOpenDatabase(force: false)

            let version = connection?.userVersion ?? 0

            if version != 0 && version < forcedUpgradeVersion {
                connection = nil
                connection = createOrOpenDatabase(force: true)
            }

            return connection
        }
    }

    func getWritableConnection() -> Connection? {
        fatalError("getWritableConnection not supported")
    }

    // MARK: - ThemeRepositoryProtocol

    /**
     * Returns a list with all categories (objects). Gets a cursor sorted in order (special identifier).
     */
    func getThemes() -> [Theme]? {
        guard let db = getReadableConnection() else {
            return nil
        }

        do {
            let query = ThemeContract.themeTable.order(ThemeContract.ordinal.asc)
            let result = Array(try db.prepare(query))
            return result.map { row in
                let point = Point(count: row[ThemeContract.count], arcade: 0, marathon: 0, sprint: 0)
                return Theme(id: row[ThemeContract.id],
                        title: row[ThemeContract.name],
                        info: row[ThemeContract.info],
                        imageName: row[ThemeContract.image],
                        count: row[ThemeContract.count],
                        point: point)
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return nil
        }
    }

    /**
    * Returns a category object based on the given id
    * @param id category id
    */
    func getTheme(id: Int) -> Theme? {
        guard let db = getReadableConnection() else {
            return nil
        }

        do {
            let query = ThemeContract.themeTable.filter(ThemeContract.id == id)
            let result = try db.pluck(query)
            return result.map { row in
                let point = Point(count: row[ThemeContract.count], arcade: 0, marathon: 0, sprint: 0)
                return Theme(id: row[ThemeContract.id],
                        title: row[ThemeContract.name],
                        info: row[ThemeContract.info],
                        imageName: row[ThemeContract.image],
                        count: row[ThemeContract.count],
                        point: point)
            }
        } catch {
            CrashlyticsUtils.record(root: error, userInfo: ["id": "\(id)"])
            return nil
        }
    }

    func getThemeTitle(id: Int) -> String? {
        guard let db = getReadableConnection() else {
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
    }

    // MARK: - QuestRepositoryProtocol

    /**
     * Initializes and returns a question object by inidi factor
     * @param id question identifier
     */
    func getQuest(id: Int) -> Quest? {
        guard let db = getReadableConnection() else {
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

                return Quest(id: Int(row[QuestContract.id]),
                        quest: questFormatter.format(data: decryptQuest),
                        trueAnswer: decryptTrueAnswer,
                        answers: decryptAnswers,
                        complexity: row[QuestContract.complexity])
            }
        } catch {
            CrashlyticsUtils.record(root: error, userInfo: ["id": "\(id)"])
            return nil
        }
    }

    /**
     * Returns all question IDs, by given category, difficulty level, and also sorts by
     * level of complexity, if required, depending on the value of the variable.
    */
    func getQuestIds(theme: Int, isSort: Bool) -> [Int]? {
        let query: Table
        if theme == Theme.defaultThemeId {
            query = QuestContract.questTable.select(QuestContract.id, QuestContract.complexity)
        } else {
            query = QuestContract.questTable
                    .select(QuestContract.id, QuestContract.complexity)
                    .filter(QuestContract.category == theme)
        }

        return getQuestIdsByQuery(query: query, isSort: isSort)
    }

    func getErrors(ids: Set<Int>) -> [ErrorQuest]? {
        guard let db = getReadableConnection() else {
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
    }

    // MARK: - SectionRepositoryProtocol

    /**
     * Determines the number of sections in the topic. 1. Launch the sections screen.
     * 2. Displaying sections (for initialization).
     */
    func getSectionCount(theme: Int) -> Int? {
        guard let db = getReadableConnection() else {
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
    }

    /**
     * Gets a list of section question IDs. There can't be a common section, otherwise everything will get mixed up.
     * Used in the game when receiving a list of questions.
     */
    func getQuestIdsBySection(theme: Int, section: Int, isSort: Bool) -> [Int]? {
        guard theme != Theme.defaultThemeId else {
            return nil
        }

        let query = QuestContract.questTable
                .select(QuestContract.id, QuestContract.complexity)
                .filter(QuestContract.category == theme && QuestContract.section == section)
        return getQuestIdsByQuery(query: query, isSort: isSort)
    }

    func getSections(theme: Int) -> [Section]? {
        guard theme != Theme.defaultThemeId else {
            return nil
        }
        guard let count = getSectionCount(theme: theme), count != 0 else {
            return nil
        }

        var result: [Section] = [Section]()
        for sectionId in 1...count {
            let questIds = getQuestIdsBySection(theme: theme, section: sectionId, isSort: false)
            let questCount = questIds?.count ?? 0
            let section = Section(id: sectionId, count: questCount, questIds: questIds, point: nil)
            result.append(section)
        }
        return result
    }

    // MARK: - Private Database

    private func createOrOpenDatabase(force: Bool) -> Connection? {
        // First check for the presence of the db file and do not try to open it
        var connection: Connection?

        if FileManager().fileExists(atPath: path) {
            connection = returnConnection()
        }

        if connection != nil {
            // the database already exists
            if force {
                // Forced database update!
                connection = nil
                copyDatabase()
                connection = returnConnection()
            }
        } else {
            // database doesn't exist, copy it from assets and return it
            copyDatabase()
            connection = returnConnection()
        }

        return connection
    }

    private func returnConnection() -> Connection? {
        do {
            return try Connection(path, readonly: true)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot connect to Database. Error is:")
            return nil
        }
    }

    private func copyDatabase() {
        let resDbPath = Bundle.main
                .path(forResource: dbFileName, ofType: ContentDatabase.dbFileExtension)!

        do {
            let fileManager = FileManager()

            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
            }

            try fileManager.copyItem(atPath: resDbPath, toPath: path)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot copy to Database. Error is:")
        }
    }

    // MARK: - Private Data

    private func getQuestIdsByQuery(query: Table, isSort: Bool) -> [Int]? {
        guard let db = getReadableConnection() else {
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
}
