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

class ThemeContract {
    static let themeTable = Table("category")

    static let id = Expression<Int>("_id")
    static let ordinal = Expression<Int>("ordinal")
    static let name = Expression<String>("name")
    static let info = Expression<String>("info")
    static let image = Expression<String>("image")
    static let count = Expression<Int>("count")
    static let count_normal = Expression<Int>("count_normal")
    static let count_easy = Expression<Int>("count_easy")
}
