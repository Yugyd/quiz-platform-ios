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

protocol QuestDatabaseProtocol: AnyObject {

    /**
     * Initializes and returns a question object by inidifactor
     * @param id question identifier
     */
    func getQuest(id: Int) async throws -> Quest?
    
    func addQuests(quests: [Quest]?) async throws

    /**
     * Returns all question IDs, by given category, difficulty level, and also sorts by
     * difficulty level, if required.
     */
    func getQuestIds(theme: Int, isSort: Bool) async throws -> [Int]?

    /**
     * Returns questions that contain errors.
     */
    func getErrors(ids: Set<Int>) async throws -> [ErrorQuest]?
}
