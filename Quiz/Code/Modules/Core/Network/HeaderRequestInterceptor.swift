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

final class HeaderRequestInterceptor: RequestInterceptor {
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        let aiConnectionClient: AiConnectionClient = IocContainer.app.resolve()
        let logger: Logger = IocContainer.app.resolve()
        
        var request = urlRequest
        
        Task {
            do {
                let aiConnection = try await aiConnectionClient.getAiConnection()
                
                if let ai = aiConnection {
                    request.setValue(ai.apiKey, forHTTPHeaderField: "X-Ai-Key")
                    request.setValue(ai.apiProvider.qualifier, forHTTPHeaderField: "X-Ai-Provider")
                    
                    if let folder = ai.apiCloudFolder {
                        request.setValue(folder, forHTTPHeaderField: "X-Ai-Folder")
                    }
                }
                
                completion(.success(request))
            } catch {
                logger.logError(error: error)
                
                completion(.success(request))
            }
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}
