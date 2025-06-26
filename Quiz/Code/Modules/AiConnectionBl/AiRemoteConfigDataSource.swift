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

internal class AiRemoteConfigDataSource: AiRemoteConfigSource {
    
    private let remoteConfig: AppRemoteConfig
    private let aiInstructionConfigMapper: AiInstructionConfigMapper
    private let logger: Logger
    private let jsonDecoder: JSONDecoder

    private let API_KEY_INSTRUCTION_URL_KEY = "api_key_instruction_url"
    private let AI_PRIVACY_URL_KEY = "ai_privacy_url"

    init(
        remoteConfig: AppRemoteConfig,
        aiInstructionConfigMapper: AiInstructionConfigMapper,
        logger: Logger,
        jsonDecoder: JSONDecoder
    ) {
        self.remoteConfig = remoteConfig
        self.aiInstructionConfigMapper = aiInstructionConfigMapper
        self.logger = logger
        self.jsonDecoder = jsonDecoder
    }

    func getAiInstructionConfigs() async -> [AiInstructionConfig] {
        do {
            let jsonString = remoteConfig.fetchStringValue(key: API_KEY_INSTRUCTION_URL_KEY)
            guard let data = jsonString.data(using: .utf8) else {
                logger.print(message: "Invalid JSON encoding")

                return []
            }

            let dtoList = try jsonDecoder.decode([AiInstructionConfigDto].self, from: data)
            return dtoList.map { aiInstructionConfigMapper.map(dto: $0) }
        } catch {
            logger.logError(error: error)

            return []
        }
    }

    func getAiPrivacyUrl() async -> String? {
        do {
            return remoteConfig.fetchStringValue(key: AI_PRIVACY_URL_KEY)
        } catch {
            logger.logError(error: error)
          
            return nil
        }
    }
}
