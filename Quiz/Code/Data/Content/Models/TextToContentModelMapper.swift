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

protocol TextToContentModelMapper {
    func map(raw: RawContentDataModel) -> ContentDataModel
}

class TextToContentModelMapperImpl: TextToContentModelMapper {
    
    func map(raw: RawContentDataModel) -> ContentDataModel {
        let quests = raw.rawQuests.enumerated().map { index, item in
            mapToQuestEntity(
                item: item,
                id: index + 1
            )
        }
        
        let themes = raw.rawCategories.enumerated().map { index, item in
            let mappedItem = mapToThemeEntity(
                item: item,
                ordinal: index
            )
            let count = quests.filter {
                $0.category == mappedItem.id
            }.count
            
            let updatedTheme = Theme(
                id: mappedItem.id,
                name: mappedItem.name,
                info: mappedItem.info,
                image: mappedItem.image,
                count: count,
                ordinal: mappedItem.ordinal,
                point: mappedItem.point
            )
            
            return updatedTheme
        }
        
        return ContentDataModel(
            quests: quests,
            themes: themes
        )
    }
    
    private func mapToQuestEntity(item: String, id: Int) -> Quest {
        let data = item.split(separator: "\n")
        
        let trueAnswer = String(data[1])
        return Quest(
            id: id,
            quest: String(data[0]),
            trueAnswer: trueAnswer,
            answers: [
                trueAnswer,
                String(data[2]),
                String(data[3]),
                String(data[4]),
                "",
                "",
                "",
                ""
            ],
            complexity: Int(String(data[5])) ?? 0,
            category: Int(String(data[6])) ?? 0,
            section: Int(String(data[7])) ?? 0
        )
    }
    
    private func mapToThemeEntity(item: String, ordinal: Int) -> Theme {
        let data = item.split(separator: "\n")
        
        let defaultPoint = Point(
            count: 0,
            arcade: 0 ,
            marathon: 0,
            sprint: 0
        )
        
        if data.count == 3 {
            return Theme(
                id: Int(String(data[0])) ?? 0,
                name: String(data[1]),
                info: String(data[2]),
                image: nil,
                count: 0,
                ordinal: ordinal,
                point: defaultPoint
            )
        } else {
            return Theme(
                id: Int(String(data[0])) ?? 0,
                name: String(data[1]),
                info: String(data[2]),
                image: String(data[3]),
                count: 0,
                ordinal: ordinal,
                point: defaultPoint
            )
        }
    }
}
