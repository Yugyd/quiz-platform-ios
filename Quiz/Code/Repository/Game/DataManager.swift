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

class DataManager: DataManagerProtocol {

    typealias QuestSectionRepositoryProtocol = QuestRepositoryProtocol & SectionRepositoryProtocol

    var mode: Mode

    private var contentRepository: QuestSectionRepositoryProtocol
    private var userRepository: UserRepositoryProtocol
    private var aiTasksInteractor: AiTasksInteractor

    init(
        contentRepository: QuestSectionRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        aiTasksInteractor: AiTasksInteractor,
        mode: Mode
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.aiTasksInteractor = aiTasksInteractor

        self.mode = mode
    }

    func loadQuest(id: Int, theme: Int) async throws-> Quest? {
        switch mode {
        case .arcade, .marathon, .sprint, .error:
            return try await contentRepository.getQuest(id: id)
        case .aiTasks:
            return try aiTasksInteractor.getQuest(aiThemeId: theme, aiQuestId: id)
        case .unused:
            fatalError()
        }
        
    }

    func loadQuestIds(theme: Int, section: Int?, isSort: Bool) async throws -> [Int]? {
        switch mode {
        case .arcade:
            if let section = section {
                return try await contentRepository.getQuestIdsBySection(theme: theme, section: section, isSort: isSort)
            } else {
                return nil
            }
        case .marathon, .sprint:
            return try await contentRepository.getQuestIds(theme: theme, isSort: isSort)
        case .error:
            return try await userRepository.getErrorIds()
        case .aiTasks:
            return aiTasksInteractor.getQuestIds(aiThemeId: theme)
        case .unused: fatalError()
        }
    }

    func saveSectionData(theme: Int, section: Int?, sectionQuestIds: Set<Int>) async throws-> Int {
        guard mode == .arcade, let section = section else {
            return 0
        }

        let resetIds = try await contentRepository.getQuestIdsBySection(theme: theme, section: section, isSort: false)
        _ = try await self.userRepository.resetSectionProgress(questIds: resetIds)
        try await self.userRepository.updateSectionProgress(questIds: sectionQuestIds)

        let allIds = try await contentRepository.getQuestIds(theme: theme, isSort: false)
        return try await userRepository.getTotalProgressSections(questIds: allIds)
    }

    func saveRecord(theme: Int, point: Int, time: Int) async throws {
        switch mode {
        case .arcade, .marathon, .sprint:
            try await userRepository.addRecord(mode: mode, theme: theme, value: point, time: time)
        case .error, .aiTasks: break
        case .unused: fatalError()
        }
    }

    func saveErrorData(errorQuestIds: Set<Int>?, rightQuestIds: Set<Int>?) async throws {
        switch mode {
        case .arcade, .marathon, .sprint:
            guard let errorQuestIds = errorQuestIds else {
                return
            }
            try await userRepository.updateErrors(errors: errorQuestIds)
        case .error:
            guard let rightQuestIds = rightQuestIds else {
                return
            }
            try await userRepository.resolveErrors(resolved: rightQuestIds)
        case .aiTasks:
            return
        case .unused: fatalError()
        }
    }
}
