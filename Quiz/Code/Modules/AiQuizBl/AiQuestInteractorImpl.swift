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

final class AiQuestInteractorImpl: AiQuestInteractor {
    private let remoteSource: AiQuestRemoteSource
    
    init(remoteSource: AiQuestRemoteSource) {
        self.remoteSource = remoteSource
    }
    
    func getTasks(themeId: Int) async throws -> [AiTaskModel] {
        try await remoteSource.getTasks(themeId: themeId)
    }
    
    func verifyTask(quest: String, userAnswer: String, trueAnswer: String) async throws -> AiVerifyTaskModel {
        try await remoteSource.verifyTask(quest: quest, userAnswer: userAnswer, trueAnswer: trueAnswer)
    }
    
    func getThemes(parentThemeId: Int?) async throws -> [AiThemeModel] {
        try await remoteSource.getThemes(parentThemeId: parentThemeId)
    }
    
    func getThemeDetail(themeId: Int) async throws -> AiThemeDetailModel {
        try await remoteSource.getThemeDetail(themeId: themeId)
    }
}
