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

final class QuizPlatformApiImpl: QuizPlatformApi {
    
    private let session: Session
    
    init(networkManager: NetworkFactory) {
        self.session = networkManager.getSession()
    }
    
    func getTasks(themeId: Int) async throws -> [TaskDto] {
        let url = NetworkFactory.baseURL.appendingPathComponent("tasks/\(themeId)")
       
        let response = try await session.request(url, method: .get)
            .serializingDecodable([TaskDto].self)
            .value
      
        return response
    }
    
    func verifyTask(request: VerifyTaskRequest) async throws -> VerifyTaskDto {
        let url = NetworkFactory.baseURL.appendingPathComponent("tasks/verification")
       
        let response = try await session.request(
            url,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default
        )
            .serializingDecodable(VerifyTaskDto.self)
            .value
      
        return response
    }
    
    func getThemes(parentThemeId: Int?) async throws -> [ThemeDto] {
        var urlComponents = URLComponents(
            url: NetworkFactory.baseURL.appendingPathComponent("themes"),
            resolvingAgainstBaseURL: false
        )!
       
        if let parentThemeId = parentThemeId {
            urlComponents.queryItems = [
                URLQueryItem(
                    name: "parentThemeId",
                    value: "\(parentThemeId)"
                )
            ]
       
        }
      
        let url = urlComponents.url!
    
        let response = try await session.request(
            url,
            method: .get
        )
            .serializingDecodable([ThemeDto].self)
            .value
        
        return response
    }
    
    func getThemeDetail(themeId: Int, recreate: Bool = true) async throws -> ThemeDetailDto {
        var urlComponents = URLComponents(
            url: NetworkFactory.baseURL.appendingPathComponent("themes/\(themeId)"),
            resolvingAgainstBaseURL: false
        )!
     
        urlComponents.queryItems = [URLQueryItem(name: "recreate", value: recreate ? "true" : "false")]
       
        let url = urlComponents.url!
       
        let response = try await session.request(
            url,
            method: .get
        )
            .serializingDecodable(ThemeDetailDto.self)
            .value

        return response
    }
}
