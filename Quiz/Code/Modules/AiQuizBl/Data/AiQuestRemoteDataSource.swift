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

import Alamofire

final class AiQuestRemoteDataSource: AiQuestRemoteSource {
  
    private let api: QuizPlatformApi
    private let mapper: AiQuestMapper
    
    init(
        api: QuizPlatformApi,
        mapper: AiQuestMapper
    ) {
        self.api = api
        self.mapper = mapper
    }
    
    func getTasks(themeId: Int) async throws -> [AiTaskModel] {
        try await processResponse(
            apiRequest: { try await api.getTasks(themeId: themeId) },
            mapper: { $0.map(mapper.map) }
        )
    }
    
    func verifyTask(quest: String, userAnswer: String, trueAnswer: String) async throws -> AiVerifyTaskModel {
        let req = VerifyTaskRequest(quest: quest, userAnswer: userAnswer, trueAnswer: trueAnswer)
        return try await processResponse(
            apiRequest: { try await api.verifyTask(request: req) },
            mapper: mapper.map
        )
    }
    
    func getThemes(parentThemeId: Int?) async throws -> [AiThemeModel] {
        try await processResponse(
            apiRequest: { try await api.getThemes(parentThemeId: parentThemeId) },
            mapper: { $0.map(mapper.map) }
        )
    }
    
    func getThemeDetail(themeId: Int) async throws -> AiThemeDetailModel {
        try await processResponse(
            apiRequest: { try await api.getThemeDetail(themeId: themeId, recreate: true) },
            mapper: mapper.map
        )
    }
    
    private func processResponse<T, R>(
        apiRequest: () async throws -> T,
        mapper: (T) -> R
    ) async throws -> R {
        do {
            let dto = try await apiRequest()
            return mapper(dto)
        } catch let afError as AFError {
            // You may want to decode the error further
            if let responseCode = afError.responseCode {
                switch responseCode {
                case 400:
                    throw AiQuestRemoteError.invalidContent(message: afError.errorDescription)
                case 404:
                    throw AiQuestRemoteError.contentNotFound(message: afError.errorDescription)
                default:
                    throw AiQuestRemoteError.httpError(statusCode: responseCode, message: afError.errorDescription)
                }
            }
            throw afError
        }
    }
}
