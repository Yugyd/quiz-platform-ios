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

struct TaskDto: Codable {
    let id: Int
    let quest: String
    let image: String?
    let trueAnswer: String
    let answer2: String?
    let answer3: String?
    let answer4: String?
    let answer5: String?
    let answer6: String?
    let answer7: String?
    let answer8: String?
    let complexity: Int
    let category: Int
    let section: Int
    let type: String?
}
