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
import GRDB

struct QuestRecord: Codable, FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "quest"
    struct Columns {
        static let id = Column("_id")
        static let quest = Column("quest")
        static let image = Column("image")
        static let true_answer = Column("true_answer")
        static let answer2 = Column("answer2")
        static let answer3 = Column("answer3")
        static let answer4 = Column("answer4")
        static let answer5 = Column("answer5")
        static let answer6 = Column("answer6")
        static let answer7 = Column("answer7")
        static let answer8 = Column("answer8")
        static let complexity = Column("complexity")
        static let category = Column("category")
        static let section = Column("section")
        static let type = Column("type")
    }
    
    var _id: Int?
    var quest: String
    var image: String?
    var true_answer: String
    var answer2: String?
    var answer3: String?
    var answer4: String?
    var answer5: String?
    var answer6: String?
    var answer7: String?
    var answer8: String?
    var complexity: Int
    var category: Int
    var section: Int
    var type: String?
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(
        insert: .replace,
        update: .replace
    )
}
