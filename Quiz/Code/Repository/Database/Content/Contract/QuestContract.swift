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

import SQLite

class QuestContract {
    static let questTable = Table("quest")

    static let id = Expression<Int>("_id")
    static let quest = Expression<String>("quest")
    static let true_answer = Expression<String>("true_answer")
    static let answer2 = Expression<String>("answer2")
    static let answer3 = Expression<String>("answer3")
    static let answer4 = Expression<String>("answer4")
    static let answer5 = Expression<String?>("answer5")
    static let answer6 = Expression<String?>("answer6")
    static let answer7 = Expression<String?>("answer7")
    static let answer8 = Expression<String?>("answer8")
    static let complexity = Expression<Int>("complexity")
    static let category = Expression<Int>("category")
    static let section = Expression<Int>("section")
}
