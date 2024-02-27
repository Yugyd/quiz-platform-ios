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

class UserRepository: UserRepositoryProtocol {

    private let userDb: UserDatabaseProtocol

    init(userDb: UserDatabaseProtocol) {
        self.userDb = userDb
    }

//    MARK: - RecordRepositoryProtocol

    func addRecord(mode: Mode, theme: Int, value: Int, time: Int) {
        return userDb.addRecord(mode: mode, theme: theme, value: value, time: time)
    }

//    MARK: - PointRepositoryProtocol

    func attachPoints(themes: [Theme]) -> [Theme] {
        return userDb.attachPoints(themes: themes)
    }

//    MARK: - ErrorRepositoryProtocol

    func getErrorIds() -> [Int]? {
        return userDb.getErrorIds()
    }

    func isHaveErrors() -> Bool {
        return userDb.isHaveErrors()
    }

    func updateErrors(errors: Set<Int>) {
        userDb.updateErrors(errors: errors)
    }

    func resolveErrors(resolved: Set<Int>) {
        userDb.resolveErrors(resolved: resolved)
    }

//    MARK: - ResetRepositoryProtocol

    func resetThemeProgress(theme: Int) -> Bool {
        return userDb.resetThemeProgress(theme: theme)
    }

    func resetSectionProgress(questIds: [Int]?) -> Bool {
        return userDb.resetSectionProgress(questIds: questIds)
    }

    func reset() -> Bool {
        return userDb.reset()
    }

//    MARK: - SectionPointRepositoryProtocol

    func attachPoints(sections: [Section]) -> [Section] {
        userDb.attachPoints(sections: sections)
    }

    func updateSectionProgress(questIds: Set<Int>) {
        userDb.updateSectionProgress(questIds: questIds)
    }

    func getTotalProgressSections(questIds: [Int]?) -> Int {
        return userDb.getTotalProgressSections(questIds: questIds)
    }
}
