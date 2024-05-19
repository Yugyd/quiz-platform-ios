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
import Combine

class UserDatabase: SqliteDatabase, LifecycleSqlDatabase, UserDatabaseProtocol {
    
    private static let dbFileName = "userdata.db"
    private let loggerTag = "UserDatabase"
    
    private let newVersion: Int
    private let logger: Logger
    private let path: String
    private var connection: Connection?
    private var isInitializing: Bool = false
    
    private var contentsSubject: CurrentValueSubject<[ContentModel], Never>?
    
    init(
        version: Int,
        logger: Logger
    ) {
        self.logger = logger
        self.newVersion = version
        self.path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first! + "/\(UserDatabase.dbFileName)"
    }
    
    // MARK: - SqliteDatabaseProtocol
    
    func getReadableConnection() -> Connection? {
        return getWritableConnection()
    }
    
    func getWritableConnection() -> Connection? {
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
                
                onFill(db: connection)
            } else {
                if version < newVersion {
                    onUpgrade(db: connection, oldVersion: Int(version), newVersion: newVersion)
                }
            }
            
            connection.userVersion = Int32(newVersion)
        }
        
        return connection
    }
    
    // MARK: - SqliteDatabaseProtocol
    
    func onCreate(db: Connection) {
        do {
            try db.run(ModeContract.table.create(ifNotExists: true) { t in
                t.column(ModeContract.id, primaryKey: true)
                t.column(ModeContract.title)
            })
            
            try db.run(RecordContract.table.create(ifNotExists: true) { t in
                t.column(RecordContract.id, primaryKey: .autoincrement)
                t.column(RecordContract.themeId)
                t.column(RecordContract.modeId)
                // t.column(PointContract.modeId, references: ModeContract.table, ModeContract.id)
                t.column(RecordContract.record)
                t.column(RecordContract.complexity)
                t.column(RecordContract.total_time)
            })
            
            try db.run(ContentContract.table.create(ifNotExists: true) { t in
                t.column(ContentContract.id, primaryKey: .autoincrement)
                t.column(ContentContract.name)
                t.column(ContentContract.filePath)
                t.column(ContentContract.isChecked)
                t.column(ContentContract.contentMarker)
            })
            
            try db.run(ErrorContract.table.create(ifNotExists: true) { t in
                t.column(ErrorContract.id, primaryKey: true)
            })
            
            try db.run(SectionContract.table.create(ifNotExists: true) { t in
                t.column(SectionContract.id, primaryKey: true)
            })
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot create table to Database. Error is:")
        }
    }
    
    func onUpgrade(db: Connection, oldVersion: Int?, newVersion: Int?) {
        
    }
    
    // MARK: - RecordRepositoryProtocol
    
    func addRecord(mode: Mode, theme: Int, value: Int, time: Int) {
        guard let db = getWritableConnection() else {
            return
        }
        guard mode != .error else {
            return
        }
        
        do {
            let dbMode = DatabaseMode(mode: mode)
            
            let timeQuery = RecordContract.table
                .select(RecordContract.total_time)
                .filter(RecordContract.themeId == theme && RecordContract.modeId == dbMode.id)
            
            let data = try db.pluck(timeQuery).map {
                $0[RecordContract.total_time]
            }
            
            let totalTime: Int
            if let data = data {
                totalTime = data
            } else {
                totalTime = 0
            }
            
            let newTotalTime = (totalTime) + time
            
            // Bool isContainsRecord
            let filterQuery = RecordContract.table
                .filter(RecordContract.themeId == theme && RecordContract.modeId == dbMode.id)
            
            let query: Table
            if try db.scalar(filterQuery.count) > 0 {
                query = filterQuery
                let update = query.update(RecordContract.modeId <- dbMode.id,
                                          RecordContract.themeId <- theme,
                                          RecordContract.record <- value,
                                          RecordContract.total_time <- newTotalTime)
                try db.run(update)
            } else {
                query = RecordContract.table
                let insert = query.insert(or: .replace,
                                          RecordContract.modeId <- dbMode.id,
                                          RecordContract.themeId <- theme,
                                          RecordContract.record <- value,
                                          RecordContract.total_time <- newTotalTime)
                try db.run(insert)
            }
        } catch {
            CrashlyticsUtils.record(root: error,
                                    userInfo: [
                                        "mode": "\(mode)",
                                        "theme": "\(theme)",
                                        "value": "\(value)",
                                        "time": "\(time)", ],
                                    isPrint: true)
        }
    }
    
    // MARK: - PointRepositoryProtocol
    
    func attachPoints(themes: [Theme]) -> [Theme] {
        guard let db = getWritableConnection() else {
            return themes
        }
        
        var newThemes: [Theme] = []
        do {
            let query = RecordContract.table
                .order(RecordContract.themeId.asc, RecordContract.modeId.asc)
            
            let arcadeMode = DatabaseMode(mode: .arcade)
            let marathonMode = DatabaseMode(mode: .marathon)
            let sprintMode = DatabaseMode(mode: .sprint)
            
            let records = Array(try db.prepare(query)).map { row in
                Record(id: row[RecordContract.id],
                       themeId: row[RecordContract.themeId],
                       modeId: row[RecordContract.modeId],
                       record: row[RecordContract.record],
                       totalTime: row[RecordContract.total_time])
            }
            
            for theme in themes {
                let themeRecords = records.filter { record in
                    record.themeId == theme.id
                }
                
                let count = theme.count
                let arcade = themeRecords.first {
                    $0.modeId == arcadeMode.id
                }?
                    .record ?? 0
                let marathon = themeRecords.first {
                    $0.modeId == marathonMode.id
                }?
                    .record ?? 0
                let sprint = themeRecords.first {
                    $0.modeId == sprintMode.id
                }?
                    .record ?? 0
                
                let point = Point(count: count, arcade: arcade, marathon: marathon, sprint: sprint)
                
                let newTheme = Theme(
                    id: theme.id,
                    name: theme.name,
                    info: theme.info,
                    image: theme.image,
                    count: theme.count,
                    ordinal: theme.ordinal,
                    point: point
                )
                newThemes.append(newTheme)
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
        }
        
        return newThemes
    }
    
    // MARK: - ErrorRepositoryProtocol
    
    func getErrorIds() -> [Int]? {
        guard let db = getWritableConnection() else {
            return nil
        }
        
        do {
            return try db.prepare(ErrorContract.table).map({ $0[ErrorContract.id] }).shuffled()
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return nil
        }
    }
    
    func isHaveErrors() -> Bool {
        guard let db = getWritableConnection() else {
            return false
        }
        
        do {
            let count = try db.scalar(ErrorContract.table.count)
            return count > 0
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return false
        }
    }
    
    func updateErrors(errors: Set<Int>) {
        guard !(errors.isEmpty) else {
            return
        }
        insertSetItems(items: errors, table: ErrorContract.table, column: ErrorContract.id)
    }
    
    func resolveErrors(resolved: Set<Int>) {
        guard let db = getWritableConnection() else {
            return
        }
        
        do {
            let query = ErrorContract.table.filter(resolved.contains(ErrorContract.id))
            try db.run(query.delete())
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
        }
    }
    
    // MARK: - ResetRepositoryProtocol
    
    func resetThemeProgress(theme: Int) -> Bool {
        let record = RecordContract.table.filter(RecordContract.themeId == theme)
        return resetTable(query: record)
    }
    
    func resetSectionProgress(questIds: [Int]?) -> Bool {
        guard let questIds = questIds else {
            return false
        }
        
        let setIds = Set(questIds)
        let section = SectionContract.table.filter(setIds.contains(SectionContract.id))
        return resetTable(query: section)
    }
    
    func reset() -> Bool {
        guard let db = getWritableConnection() else {
            return false
        }
        
        do {
            try db.run(RecordContract.table.drop(ifExists: true))
            try db.run(ErrorContract.table.drop(ifExists: true))
            try db.run(SectionContract.table.drop(ifExists: true))
            
            onCreate(db: db)
            return true
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return false
        }
    }
    
    // MARK: - SectionPointRepositoryProtocol
    
    func attachPoints(sections: [Section]) -> [Section] {
        guard let db = getWritableConnection() else {
            return sections
        }
        
        var newSections: [Section] = []
        do {
            let result = try db.prepare(SectionContract.table).map({ $0[SectionContract.id] })
            if result.isEmpty {
                return sections
            }
            
            for section in sections {
                let point: Int
                if section.questIds != nil {
                    point = section.questIds!.filter {
                        result.contains($0)
                    }
                    .count
                } else {
                    point = 0
                }
                
                let newSection = Section(id: section.id, count: section.count, questIds: section.questIds, point: point)
                newSections.append(newSection)
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
        }
        
        return newSections
    }
    
    func updateSectionProgress(questIds: Set<Int>) {
        guard !(questIds.isEmpty) else {
            return
        }
        insertSetItems(items: questIds, table: SectionContract.table, column: SectionContract.id)
    }
    
    func getTotalProgressSections(questIds: [Int]?) -> Int {
        guard let db = getWritableConnection() else {
            return 0
        }
        guard let questIds = questIds else {
            return 0
        }
        
        do {
            let query = SectionContract.table.filter(questIds.contains(SectionContract.id))
            return try db.scalar(query.count)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
            return 0
        }
    }
    
    // MARK: - ContentRepositoryProtocol
    
    func getContents() -> [ContentModel] {
        guard let db = getReadableConnection() else {
            logger.print(
                tag: loggerTag,
                message: "Get contents is failed. Connection not found"
            )
            
            return []
        }
        
        do {
            let result = try Array(db.prepare(ContentContract.table))
            
            let contents: [ContentModel]
            if result.isEmpty {
                contents = []
            } else {
                contents = result.map(mapToContentModel)
            }
            
            logger.print(
                tag: loggerTag,
                message: "Get contents: \(contents)"
            )
            
            return contents
        } catch {
            CrashlyticsUtils.record(
                root: error,
                userInfo: ["Error fetching contents:": "\(error)"]
            )
            return []
        }
    }
    
    func subscribeToContentsPublisher() -> AnyPublisher<[ContentModel], Never> {
        fetchContents()

        return contentsSubject!.eraseToAnyPublisher()
    }
    
    func getSelectedContent() -> ContentModel? {
        guard let db = getReadableConnection() else {
            return nil
        }
        
        do {
            let query = ContentContract.table
                .filter(
                    ContentContract.isChecked
                )
                .limit(1)
            let result = try db.pluck(query)
            
            if result != nil {
                return result.map(mapToContentModel)
            } else {
                return nil
            }
        } catch {
            CrashlyticsUtils.record(
                root: error,
                userInfo: ["Error fetching contents:": "\(error)"]
            )
            return nil
        }
    }
    
    func subscribeToSelectedContentPublisher() -> AnyPublisher<ContentModel?, Never> {
        fetchContents()

        return contentsSubject!
            .map<ContentModel?> { key in
                let result = key.filter { model in
                    model.isChecked == true
                }
                
                if !result.isEmpty {
                    return result.first
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    func deleteContent(id: String) {
        guard let db = getWritableConnection() else {
            return
        }
        
        do {
            let query = ContentContract.table
                .filter(
                    ContentContract.id == Int(id)!
                )
                .delete()
            
            try db.run(query)
            
            fetchContents()
        } catch {
            CrashlyticsUtils.record(
                root: error,
                isPrint: true,
                startMsg: "Cannot fill table to Database. Error is:"
            )
        }
    }
    
    func addContent(contentModel: ContentModel) {
        guard let db = getWritableConnection() else {
            return
        }
        
        do {
            let query = ContentContract.table
                .insert(
                    or:.replace,
                    ContentContract.name <- contentModel.name,
                    ContentContract.filePath <- contentModel.filePath,
                    ContentContract.isChecked <- contentModel.isChecked,
                    ContentContract.contentMarker <- contentModel.contentMarker
                )
            
            try db.run(query)
            
            fetchContents()
        } catch {
            CrashlyticsUtils.record(
                root: error,
                isPrint: true,
                startMsg: "Cannot fill table to Database. Error is:"
            )
        }
    }
    
    func updateContent(contentModel: ContentModel) {
        guard let db = getWritableConnection() else {
            return
        }
        
        do {
            let query = ContentContract.table
                .filter(
                    ContentContract.id == Int(contentModel.id)!
                )
                .update(
                    ContentContract.id <- Int(contentModel.id)!,
                    ContentContract.name <- contentModel.name,
                    ContentContract.filePath <- contentModel.filePath,
                    ContentContract.isChecked <- contentModel.isChecked,
                    ContentContract.contentMarker <- contentModel.contentMarker
                )
            
            try db.run(query)
            
            fetchContents()
        } catch {
            CrashlyticsUtils.record(
                root: error,
                isPrint: true,
                startMsg: "Cannot fill table to Database. Error is:"
            )
        }
    }
    
    // MARK: - Private func
    
    private func onFill(db: Connection) {
        do {
            try db.execute(getModeSqlInjection())
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot fill table to Database. Error is:")
        }
    }
    
    private func getModeSqlInjection() -> String {
        var sqlInjection = "BEGIN TRANSACTION;"
        
        for dbMode in DatabaseMode.allCases() {
            sqlInjection.append("INSERT INTO \(ModeContract.tableName) VALUES(\(dbMode.id), \"\(dbMode.mode)\");")
        }
        
        sqlInjection.append("COMMIT TRANSACTION;")
        return sqlInjection
    }
    
    private func resetTable(query: Table) -> Bool {
        guard let db = getWritableConnection() else {
            return false
        }
        
        do {
            if try db.run(query.delete()) > 0 {
                return true
            } else {
                return false
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Cannot reset table to Database. Error is:")
            return false
        }
    }
    
    private func insertSetItems(items: Set<Int>, table: Table, column: Expression<Int>) {
        guard let db = getWritableConnection() else {
            return
        }
        
        do {
            try db.transaction {
                for item in items {
                    try db.run(table.insert(or: .ignore, column <- item))
                }
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true)
        }
    }
    
    // MARK: Content
    private func fetchContents() {
        if contentsSubject == nil {
            contentsSubject = CurrentValueSubject<[ContentModel], Never>(getContents())
        }

        let items = getContents()
        
        logger.print(
            tag: loggerTag,
            message: "Fetch contents: \(items.count)"
        )
        
        contentsSubject!.send(items)
    }
    
    private func mapToContentModel(row: Row) -> ContentModel {
        return ContentModel(
            id: String(row[ContentContract.id]),
            name: row[ContentContract.name],
            filePath: row[ContentContract.filePath],
            isChecked: row[ContentContract.isChecked],
            contentMarker: row[ContentContract.contentMarker]
        )
    }
}
