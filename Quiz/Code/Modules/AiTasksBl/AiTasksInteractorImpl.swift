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

final class AiTasksInteractorImpl: AiTasksInteractor {
    
    private let aiQuestInteractor: AiQuestInteractor
    private let aiTasksInMemorySource: AiTasksInMemorySource

    init(
        aiQuestInteractor: AiQuestInteractor,
        aiTasksInMemorySource: AiTasksInMemorySource
    ) {
        self.aiQuestInteractor = aiQuestInteractor
        self.aiTasksInMemorySource = aiTasksInMemorySource
    }

    func getQuestIds(aiThemeId: Int) -> [Int] {
        let tasks = getAiTasks(aiThemeId: aiThemeId)
        return tasks.map { $0.id }
    }

    func getQuests(aiThemeId: Int) -> [Quest] {
        let tasks = getAiTasks(aiThemeId: aiThemeId)
        return tasks.map { AiTaskModelQuestMapper.map($0) }
    }

    func getQuest(aiThemeId: Int, aiQuestId: Int) throws -> Quest {
        let tasks = getAiTasks(aiThemeId: aiThemeId)
       
        guard let aiTask = tasks.first(where: { $0.id == aiQuestId }) else {
            throw NSError(domain: "AiTasksInteractor", code: 404, userInfo: [NSLocalizedDescriptionKey: "AiTask not found"])
        }
       
        return AiTaskModelQuestMapper.map(aiTask)
    }

    func fetchAiTasks(aiThemeId: Int) async throws {
        let aiTasks = try await aiQuestInteractor.getTasks(themeId: aiThemeId)
        let aiTasksModel = AiTasksModel(aiThemeId: aiThemeId, aiTasks: aiTasks)
                
        aiTasksInMemorySource.updateCachedAiTasks(aiTasksModel: aiTasksModel)
    }

    func getAiTasks(aiThemeId: Int) -> [AiTaskModel] {
        let cached = aiTasksInMemorySource.cachedAiTasks
        
        if let model = cached.first(where: { $0.aiThemeId == aiThemeId }) {
            return model.aiTasks
        } else {
            return []
        }
    }
    
    func isHaveAiTasks(aiThemeId: Int) -> Bool {
        return !getAiTasks(aiThemeId: aiThemeId).isEmpty
    }
}
