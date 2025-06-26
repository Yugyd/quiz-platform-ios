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
import Combine

final class AiConnectionClientImpl: AiConnectionClient {
    
    private let aiConnectionLocalSource: AiConnectionLocalSource
    private let logger: Logger
    
    init(aiConnectionLocalSource: AiConnectionLocalSource, logger: Logger) {
        self.aiConnectionLocalSource = aiConnectionLocalSource
        self.logger = logger
    }
    
    func isActiveAiConnection() async throws -> Bool {
        return try await !aiConnectionLocalSource.getConnections().isEmpty
    }
    
    func subscribeToCurrentAiConnection() -> AnyPublisher<AiConnectionModel?, Never> {
        aiConnectionLocalSource.subscribeToConnections()
            .map { $0.first(where: { $0.isActive }) }
            .eraseToAnyPublisher()
    }
    
    func addAiConnection(model: UpdateAiConnectionModel) async -> Bool {
        do {
            let newIdString = "\(model.apiKey)\(model.apiProvider)"
            guard let base64Id = newIdString.data(using: .utf8)?.base64EncodedString() else {
                return false
            }
            
            let newConnection = AiConnectionModel(
                id: base64Id,
                isActive: true,
                name: model.name,
                apiProvider: model.apiProvider,
                apiKey: model.apiKey,
                apiCloudFolder: model.apiCloudFolder,
                isValid: nil
            )
            
            let connections = [newConnection]
            
            try await aiConnectionLocalSource.setConnections(connections)
            
            return true
        } catch {
            logger.logError(error: error)
            
            return false
        }
    }
    
    func updateAiConnection(model: UpdateAiConnectionModel) async -> Bool {
        await addAiConnection(model: model)
    }
    
    func deleteAiConnection() async -> Bool {
        do {
            try await aiConnectionLocalSource.setConnections([])
            
            return true
        } catch {
            logger.logError(error: error)
            
            return false
        }
    }
    
    func getAvailableAiProviders() async -> [AiConnectionProviderModel] {
        AiConnectionProviderTypeModel.allCases
            .filter { $0 != .none }
            .map {
                AiConnectionProviderModel(name: $0.qualifier, type: $0)
            }
    }
    
    func getAiConnection() async -> AiConnectionModel? {
        do {
            return try await aiConnectionLocalSource.getConnections().first ?? nil
        } catch {
            logger.logError(error: error)
            
            return nil
        }
    }
}
