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

struct CategoryRecord: Codable, FetchableRecord, PersistableRecord, TableRecord
{
    static let databaseTableName = "category"
    static let id = Column("_id")
    static let ordinal = Column("ordinal")
    static let name = Column("name")
    static let info = Column("info")
    static let image = Column("image")
    static let count = Column("count")
    
    var _id: Int?
    var ordinal: Int
    var name: String
    var info: String
    var image: String?
    var count: Int
    
    static let persistenceConflictPolicy = PersistenceConflictPolicy(
        insert: .replace,
        update: .replace
    )
}
