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
import GRDB

class GRDBContentDatabase: ContentDatabaseProtocol {
    
    private static let fileName = "content-encode.db"
    
    private let db: DatabaseQueue
    private let logger: Logger
    private let decoder: DecoderProtocol
    private let questFormatter: SymbolFormatter
    private let contentDbMapper: ContentDbMapper
    
    init(
        decoder: DecoderProtocol,
        questFormatter: SymbolFormatter,
        version: Int,
        logger: Logger,
        contentDbMapper: ContentDbMapper,
    ) throws {
        self.decoder = decoder
        self.questFormatter = questFormatter
        self.logger = logger
        self.contentDbMapper = contentDbMapper
        
        let dir = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let url = dir.appendingPathComponent(Self.fileName)
        
        db = try DatabaseQueue(path: url.path)
    }
    
    func getThemes() async throws -> [Theme]? {
        try await db.read { [weak self] db in
            guard let self else { return [] }
            
            let records = try CategoryRecord.order(CategoryRecord.ordinal.asc).fetchAll(db)
            
            return records.map { record in
                return self.contentDbMapper.mapToTheme(record)
            }
        }
    }
    
    func addThemes(themes: [Theme]?) async throws {
        guard let themes, !themes.isEmpty else { return }
        try await db.write { [weak self] db in
            guard let self else { return }
            
            for t in themes {
                let rec = self.contentDbMapper.mapToCategoryRecord(t)
                try rec.insert(db)
            }
        }
    }
    
    func getTheme(id: Int) async throws -> Theme? {
        try await db.read { [weak self] db -> Theme? in
            guard let self else { return nil }
            
            if let r = try CategoryRecord.fetchOne(db, key: id) {
                return contentDbMapper.mapToTheme(r)
            }
            return nil
        }
    }
    
    func getThemeTitle(id: Int) async throws -> String? {
        return try await getTheme(id: id)?.name
    }
    
    func getQuest(id: Int) async throws -> Quest? {
        try await db.read { [weak self] db in
            guard let self else { return nil }

            guard let r = try QuestRecord.fetchOne(db, key: id) else { return nil }
            
            return self.contentDbMapper.mapToQuest(r)
        }
    }
    
    func addQuests(quests: [Quest]?) async throws {
        guard let quests, !quests.isEmpty else { return }
        try await db.write { [weak self] db in
            guard let self else { return }
            
            for q in quests {
                var rec = self.contentDbMapper.mapToQuestRecord(q)
                try rec.insert(db)
            }
        }
    }
    
    func getQuestIds(theme: Int, isSort: Bool) async throws -> [Int]? {
        let questRecords = try await getQuests(theme: theme) ?? []
        
        let pairs = questRecords.map { (id: Int($0._id ?? 0), complexity: $0.complexity) }
        if isSort {
            return pairs.shuffled().sorted { $0.complexity < $1.complexity }.map { $0.id }
        } else {
            return pairs.map { $0.id }.shuffled()
        }
    }
    
    private func getQuests(theme: Int?) async throws -> [QuestRecord]? {
        try await db.read { db in
            let request: QueryInterfaceRequest<QuestRecord>
            if theme == Theme.defaultThemeId || theme == nil {
                request = QuestRecord.all()
            } else {
                request = QuestRecord.filter(QuestRecord.Columns.category == theme)
            }
            
            let records = try request.fetchAll(db)
            return records
        }
    }
    
    func getErrors(ids: Set<Int>) async throws -> [ErrorQuest]? {
        guard !ids.isEmpty else { return nil }
        
        let quests = try await getQuests(theme: nil) ?? []
        
        return quests
            .filter { ids.contains(Int($0._id ?? 0)) }
            .map { record in
                return self.contentDbMapper.mapToErrorQuest( record)
            }
    }
    
    func getSectionCount(theme: Int) async throws -> Int? {
        if theme == Theme.defaultThemeId { return nil }
        
        let quests = try await getQuests(theme: theme) ?? []
        
        return quests.map { $0.section }.max() ?? 0
    }
    
    func getQuestIdsBySection(theme: Int, section: Int, isSort: Bool) async throws -> [Int]? {
        if theme == Theme.defaultThemeId {
            return nil
        }
        
        let quests = try await getQuests(theme: theme) ?? []
        
        // фильтруем по секции
        let pairs = quests
            .filter { $0.section == section }
            .map { (id: $0._id, complexity: $0.complexity) }
        
        if isSort {
            return pairs
                .shuffled()
                .sorted { $0.complexity < $1.complexity }
                .map { $0.id! }
        } else {
            return pairs.map { $0.id! }.shuffled()
        }
    }
    
    func getSections(theme: Int) async throws -> [Section]? {
        if theme == Theme.defaultThemeId { return nil }
        
        guard let count = try await getSectionCount(theme: theme), count != 0 else { return nil }
        
        var result: [Section] = []
        
        for sid in 1...count {
            let ids = try await getQuestIdsBySection(
                theme: theme,
                section: sid,
                isSort: false
            )
            result.append(
                Section(
                    id: sid,
                    count: ids?.count ?? 0,
                    questIds: ids,
                    point: nil)
            )
        }
        
        return result
    }
    
    func reset() async throws {
        let categoryCount = try await db.write { db in try CategoryRecord.deleteAll(db) }
        let questCount = try await db.write { db in try QuestRecord.deleteAll(db) }
        logger.print(tag: "GRDBContentDatabase", message: "Reset \(categoryCount) categories and \(questCount) quests")
    }
}
