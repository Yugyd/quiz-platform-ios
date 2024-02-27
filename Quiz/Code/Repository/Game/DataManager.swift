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

class DataManager: DataManagerProtocol {

    typealias QuestSectionRepositoryProtocol = QuestRepositoryProtocol & SectionRepositoryProtocol

    var mode: Mode

    private var contentRepository: QuestSectionRepositoryProtocol
    private var userRepository: UserRepositoryProtocol

    init(contentRepository: QuestSectionRepositoryProtocol,
         userRepository: UserRepositoryProtocol,
         mode: Mode) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository

        self.mode = mode
    }

    func loadQuest(id: Int) -> Quest? {
        return contentRepository.getQuest(id: id)
    }

    func loadQuestIds(theme: Int, section: Int?, isSort: Bool) -> [Int]? {
        switch mode {
        case .arcade:
            if let section = section {
                return contentRepository.getQuestIdsBySection(theme: theme, section: section, isSort: isSort)
            } else {
                return nil
            }
        case .marathon, .sprint:
            return contentRepository.getQuestIds(theme: theme, isSort: isSort)
        case .error:
            return userRepository.getErrorIds()
        case .unused: fatalError()
        }
    }

    func saveSectionData(theme: Int, section: Int?, sectionQuestIds: Set<Int>) -> Int {
        guard mode == .arcade, let section = section else {
            return 0
        }

        let resetIds = contentRepository.getQuestIdsBySection(theme: theme, section: section, isSort: false)
        _ = self.userRepository.resetSectionProgress(questIds: resetIds)
        self.userRepository.updateSectionProgress(questIds: sectionQuestIds)

        let allIds = contentRepository.getQuestIds(theme: theme, isSort: false)
        return userRepository.getTotalProgressSections(questIds: allIds)
    }

    func saveRecord(theme: Int, point: Int, time: Int) {
        switch mode {
        case .arcade, .marathon, .sprint:
            userRepository.addRecord(mode: mode, theme: theme, value: point, time: time)
        case .error: break
        case .unused: fatalError()
        }
    }

    func saveErrorData(errorQuestIds: Set<Int>?, rightQuestIds: Set<Int>?) {
        switch mode {
        case .arcade, .marathon, .sprint:
            guard let errorQuestIds = errorQuestIds else {
                return
            }
            userRepository.updateErrors(errors: errorQuestIds)
        case .error:
            guard let rightQuestIds = rightQuestIds else {
                return
            }
            userRepository.resolveErrors(resolved: rightQuestIds)
        case .unused: fatalError()
        }
    }
}
