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

class ContentValidatorHelperImpl: ContentValidatorHelper {
    
    func validateContent(contentData: ContentDataModel) throws {
        try verifyDuplicateIds(
            items: contentData.quests,
            keyGetter: { $0.id },
            exceptionFactory: { duplicateItems in
                ContentVerificationError.duplicateIdQuests(
                    message: "Find duplicated id quests: \(duplicateItems.count)",
                    quests: duplicateItems
                )
            }
        )
        
        try verifyDuplicateIds(
            items: contentData.themes,
            keyGetter: { $0.id },
            exceptionFactory: { duplicateItems in
                ContentVerificationError.duplicateIdThemes(
                    message: "Find duplicated id themes: \(duplicateItems.count)",
                    themes: duplicateItems
                )
            }
        )
        
        try verifyItems(
            items: contentData.quests,
            predicate: isQuestValid,
            exceptionFactory: { notValidItems in
                ContentVerificationError.notValidQuests(
                    message: "Find not valid quests",
                    quests: notValidItems
                )
            }
        )
        
        try verifyItems(
            items: contentData.themes,
            predicate: isThemeValid,
            exceptionFactory: { notValidItems in
                ContentVerificationError.notValidThemes(
                    message: "Find not valid themes",
                    themes: notValidItems
                )
            }
        )
    }
    
    private func verifyDuplicateIds<T: Identifiable>(
        items: [T],
        keyGetter: (T) -> Int,
        exceptionFactory: (Set<T>) -> Error
    ) throws {
        var map = [Int: [T]]()
        for item in items {
            let key = keyGetter(item)
            map[key, default: []].append(item)
        }
        
        let duplicateIdItems = map.values.filter { $0.count > 1 }.flatMap { $0 }
        if !duplicateIdItems.isEmpty {
            throw exceptionFactory(Set(duplicateIdItems))
        }
    }
    
    private func isQuestValid(quest: Quest) -> Bool {
        return quest.id != 0 &&
        !quest.quest.isEmpty &&
        !quest.trueAnswer.isEmpty &&
        !quest.answers[0].isEmpty &&
        !quest.answers[1].isEmpty &&
        !quest.answers[2].isEmpty &&
        !quest.answers[3].isEmpty
    }
    
    private func isThemeValid(theme: Theme) -> Bool {
        return theme.id != 0 &&
        !theme.name.isEmpty &&
        !theme.info.isEmpty &&
        theme.count != 0
    }
    
    private func verifyItems<T: Identifiable>(
        items: [T],
        predicate: (T) -> Bool,
        exceptionFactory: (Set<T>) -> Error
    ) throws {
        let notValidItems = Set(items.filter { !predicate($0) })
        if !notValidItems.isEmpty {
            throw exceptionFactory(notValidItems)
        }
    }
}
