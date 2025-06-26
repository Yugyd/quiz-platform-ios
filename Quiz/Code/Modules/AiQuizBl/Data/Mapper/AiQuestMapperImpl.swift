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

final class AiQuestMapperImpl: AiQuestMapper {
    
    private static let yandexGptResponseBlock = "```"
    
    func map(_ dto: TaskDto) -> AiTaskModel {
        AiTaskModel(
            id: dto.id,
            quest: dto.quest,
            image: dto.image,
            trueAnswer: dto.trueAnswer,
            answer2: dto.answer2,
            answer3: dto.answer3,
            answer4: dto.answer4,
            answer5: dto.answer5,
            answer6: dto.answer6,
            answer7: dto.answer7,
            answer8: dto.answer8,
            complexity: dto.complexity,
            category: dto.category,
            section: dto.section,
            type: dto.type ?? "simple"
        )
    }
    
    func map(_ dto: VerifyTaskDto) -> AiVerifyTaskModel {
        AiVerifyTaskModel(
            aiTrueAnswer: dto.aiDescription,
            isValid: dto.isCorrect
        )
    }
    
    func map(_ dto: ThemeDto) -> AiThemeModel {
        AiThemeModel(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            iconUrl: dto.iconUrl,
            detail: dto.detail
        )
    }
    
    func map(_ dto: ThemeDetailDto) -> AiThemeDetailModel {
        AiThemeDetailModel(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            iconUrl: dto.iconUrl,
            detail: dto.detail,
            content: Self.clearContent(dto.content)
        )
    }
        
    private static func clearContent(_ content: String) -> String {
        if content.hasPrefix(yandexGptResponseBlock),
           content.hasSuffix(yandexGptResponseBlock) {
            return String(
                content
                    .dropFirst(yandexGptResponseBlock.count)
                    .dropLast(yandexGptResponseBlock.count)
            )
        }
        return content
    }
}
