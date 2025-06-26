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

    func addRecord(mode: Mode, theme: Int, value: Int, time: Int) async throws {
        return try await userDb.addRecord(mode: mode, theme: theme, value: value, time: time)
    }

//    MARK: - PointRepositoryProtocol

    func attachPoints(themes: [Theme]) async throws -> [Theme] {
        return try await userDb.attachPoints(themes: themes)
    }

//    MARK: - ErrorRepositoryProtocol

    func getErrorIds() async throws -> [Int]? {
        return try await userDb.getErrorIds()
    }

    func isHaveErrors() async throws -> Bool {
        return try await userDb.isHaveErrors()
    }

    func updateErrors(errors: Set<Int>) async throws {
        try await userDb.updateErrors(errors: errors)
    }

    func resolveErrors(resolved: Set<Int>) async throws {
        try await userDb.resolveErrors(resolved: resolved)
    }

//    MARK: - ResetRepositoryProtocol

    func resetThemeProgress(theme: Int) async throws -> Bool {
        return try await userDb.resetThemeProgress(theme: theme)
    }

    func resetSectionProgress(questIds: [Int]?) async throws -> Bool {
        return try await userDb.resetSectionProgress(questIds: questIds)
    }

    func reset() async throws -> Bool {
        return try await userDb.reset()
    }

//    MARK: - SectionPointRepositoryProtocol

    func attachPoints(sections: [Section]) async throws -> [Section] {
        try await userDb.attachPoints(sections: sections)
    }

    func updateSectionProgress(questIds: Set<Int>) async throws {
        try await userDb.updateSectionProgress(questIds: questIds)
    }

    func getTotalProgressSections(questIds: [Int]?) async throws -> Int {
        return try await userDb.getTotalProgressSections(questIds: questIds)
    }
}
