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

class ContentRepository: ThemeRepositoryProtocol, QuestRepositoryProtocol, SectionRepositoryProtocol, ContentResetRepositoryProtocol {

    private let contentDb: ContentDatabaseProtocol

    init(contentDb: ContentDatabaseProtocol) {
        self.contentDb = contentDb
    }

    // MARK: - ThemeRepositoryProtocol

    func getThemes() -> [Theme]? {
        return contentDb.getThemes()?.filter {
            $0.id != Theme.defaultThemeId
        }
    }
    
    func addThemes(themes: [Theme]?) {
        contentDb.addThemes(themes: themes)
    }

    func getTheme(id: Int) -> Theme? {
        return contentDb.getTheme(id: id)
    }

    func getThemeTitle(id: Int) -> String? {
        return contentDb.getThemeTitle(id: id)
    }

    // MARK: - QuestRepositoryProtocol

    func getQuest(id: Int) -> Quest? {
        return contentDb.getQuest(id: id)
    }
    
    func addQuests(quests: [Quest]?) {
        contentDb.addQuests(quests: quests)
    }

    func getQuestIds(theme: Int, isSort: Bool) -> [Int]? {
        return contentDb.getQuestIds(theme: theme, isSort: isSort)
    }

    func getErrors(ids: Set<Int>) -> [ErrorQuest]? {
        return contentDb.getErrors(ids: ids)
    }

    // MARK: - SectionRepositoryProtocol

    func getSectionCount(theme: Int) -> Int? {
        return contentDb.getSectionCount(theme: theme)
    }

    func getQuestIdsBySection(theme: Int, section: Int, isSort: Bool) -> [Int]? {
        return contentDb.getQuestIdsBySection(theme: theme, section: section, isSort: isSort)
    }

    func getSections(theme: Int) -> [Section]? {
        return contentDb.getSections(theme: theme)
    }
    
    // MARK: - ContentResetRepositoryProtocol
    
    func reset() throws {
        try contentDb.reset()
    }
}
