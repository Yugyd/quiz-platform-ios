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

class ThemePresenter: ThemePresenterProtocol {

    static let minSectionCountForStartScreen = 1

    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol

    var themes: [Theme] = [Theme]()

    var gameMode: Mode? {
        didSet {
            guard gameMode != nil else {
                return
            }
            progressCalculator = ProgressCalculator.init(mode: gameMode!)
        }
    }

    var progressCalculator: ProgressCalculator?

    weak fileprivate var rootView: ThemeViewProtocol?

    private var contentRepository: ThemeSectionRepositoryProtocol
    private var userRepository: PointRepositoryProtocol
    private var isSegueAction = false

    required init(contentRepository: ThemeSectionRepositoryProtocol, userRepository: PointRepositoryProtocol) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
    }

    func attachRootView(rootView: ThemeViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            let data = self?.contentRepository.getThemes()
            var result: [Theme]?

            if let data = data {
                result = self?.userRepository.attachPoints(themes: data)
            }

            DispatchQueue.main.async { [weak self] in
                self?.handleData(data: result)
            }
        }
    }

    func calculateProgress(point: Point) -> Int {
        return progressCalculator?.getRecordPercent(point: point) ?? 0
    }

    func startSegue(sender: IndexPath) {
        isSegueAction = true
        let themeId = themes[sender.row].id

        DispatchQueue.global().async { [weak self] in
            let isSection: Bool
            if self?.gameMode == .arcade {
                let count = self?.contentRepository.getSectionCount(theme: themeId) ?? 0
                isSection = count >= ThemePresenter.minSectionCountForStartScreen
            } else {
                isSection = false
            }

            DispatchQueue.main.async { [weak self] in
                if isSection {
                    self?.startSegueInView(startMode: .section, sender: sender)
                } else {
                    self?.startSegueInView(startMode: .game, sender: sender)
                }
            }
        }
    }

//    MARK: - Private

    private func handleData(data: [Theme]?) {
        themes = data ?? [Theme]()

        if themes.isEmpty {
            rootView?.setEmptyStub()
        } else {
            rootView?.updateCollection()
        }
    }

    private func startSegueInView(startMode: StartMode, sender: IndexPath) {
        rootView?.startSegue(startMode: startMode, sender: sender)
        isSegueAction = false
    }
}
