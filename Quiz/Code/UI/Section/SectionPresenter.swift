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

class SectionPresenter: SectionPresenterProtocol {

    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol

    var theme: Theme?
    var sections: [Section] = []
    var sectionWithLevels: [SectionWithLevel] = []

    private weak var rootView: SectionViewProtocol?

    private var themeId: Int

    private var contentRepository: ThemeSectionRepositoryProtocol
    private var userRepository: SectionPointRepositoryProtocol

    private var latestSectionId: Int?

    init(contentRepository: ThemeSectionRepositoryProtocol, userRepository: SectionPointRepositoryProtocol,
         themeId: Int) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.themeId = themeId
    }

    func attachView(rootView: SectionViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            guard let themeId = self?.themeId else {
                return
            }

            let themeData = self?.contentRepository.getTheme(id: themeId)
            let sectionsData = self?.contentRepository.getSections(theme: themeId)

            var sectionsResult: [Section]?
            if let data = sectionsData {
                sectionsResult = self?.userRepository.attachPoints(sections: data)
            }

            DispatchQueue.main.async { [weak self] in
                self?.handleData(themeData: themeData, sectionsData: sectionsResult)
            }
        }
    }

    func isLatestSection(id: Int) -> Int {
        guard let latestSectionId = latestSectionId else {
            return -1
        }

        if id < latestSectionId {
            return -1
        } else if id > latestSectionId {
            return 1
        } else {
            return 0
        }
    }

    //    MARK: - Private

    private func handleData(themeData: Theme?, sectionsData: [Section]?) {
        self.theme = themeData
        self.sections = sectionsData ?? []
        self.sectionWithLevels = sections.map {
            let percent = Percent.calculatePercent(value: ($0.point ?? 0), count: $0.count)
            return SectionWithLevel(item: $0, level: SectionLevel.defineLevel(progressPercent: percent))
        }
        self.latestSectionId = sectionWithLevels.first {
                    return $0.level == .empty || $0.level == .low
                }
                .map {
                    return $0.item.id
                }

        if sections.isEmpty {
            rootView?.setEmptyStub()
        } else {
            rootView?.updateCollection()
        }
    }
}
