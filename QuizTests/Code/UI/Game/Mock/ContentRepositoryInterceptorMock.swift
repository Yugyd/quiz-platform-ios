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
@testable import Quiz

class ContentRepositoryInterceptorMock: ContentRepository {
    
    var quest: Quest!
    var ids: [Int]?
    private var decoder = DataDecoder()
    
    override func getQuest(id: Int) -> Quest? {
        let temp = super.getQuest(id: id)
        quest = temp
        return temp
    }
    
    override func getQuestIds(theme: Int, isSort: Bool) -> [Int]? {
        let temp = super.getQuestIds(theme: theme, isSort: isSort)
        ids = temp
        return temp
    }
    
    override func getQuestIdsBySection(theme: Int, section: Int, isSort: Bool) -> [Int]? {
        let temp = super.getQuestIdsBySection(theme: theme, section: section, isSort: isSort)
        //let temp = super.getQuestIds(theme: Theme.defaultThemeId, isSort: true)
        ids = temp
        return temp
    }
}
