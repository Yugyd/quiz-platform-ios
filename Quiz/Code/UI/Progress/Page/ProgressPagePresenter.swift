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

class ProgressPagePresenter: ProgressPagePresenterProtocol {

    typealias ThemeQuestRepositoryProtocol = ThemeRepositoryProtocol & QuestRepositoryProtocol
    typealias PointResetRepositoryProtocol = ResetRepositoryProtocol & PointRepositoryProtocol

    var themeId: Int
    var theme: Theme?
    var modes: [Mode] = [.arcade, .marathon, .sprint]

    weak fileprivate var rootView: ProgressPageViewProtocol?

    private var contentRepository: ThemeQuestRepositoryProtocol
    private var userRepository: ResetRepositoryProtocol & PointRepositoryProtocol

    init(contentRepository: ThemeQuestRepositoryProtocol, userRepository: PointResetRepositoryProtocol, themeId: Int) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.themeId = themeId
    }

    func attachView(rootView: ProgressPageViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            var result: [Theme]?

            if let self = self {
                let data = self.contentRepository.getTheme(id: self.themeId)

                if let data = data {
                    result = self.userRepository.attachPoints(themes: [data])
                } else {
                    self.rootView?.setEmptyStub()
                }
            }

            DispatchQueue.main.async { [weak self] in
                let theme = result?[0] ?? nil
                self?.handleData(data: theme)
            }
        }
    }

    func resetProgress() {
        DispatchQueue.global().async { [weak self] in
            guard let theme = self?.theme else {
                return
            }

            let questIds = self?.contentRepository.getQuestIds(theme: theme.id, isSort: false)
            _ = self?.userRepository.resetSectionProgress(questIds: questIds)

            let isReset = self?.userRepository.resetThemeProgress(theme: theme.id) ?? false

            DispatchQueue.main.async { [weak self] in
                if isReset {
                    self?.loadData()
                    self?.rootView?.updateCallback?.update()
                }

                self?.rootView?.enableResetButton(isEnabled: !isReset)
            }
        }
    }

    func getProgressTitle(mode: Mode, point: Point) -> String {
        let progressValue = getProgressValue(mode: mode, point: point)

        let count: Int
        if mode == .sprint {
            count = Record.sprintRecordMax
        } else {
            count = point.count
        }

        let outOf = NSLocalizedString("OUT_OF", comment: "out of")
        return "\(progressValue) \(outOf) \(count)"
    }

    func calculateProgress(mode: Mode, point: Point) -> Int {
        return ProgressCalculator(mode: mode)?.getRecordPercent(point: point) ?? 0
    }

    func calculateTotalProgress() -> Int {
        guard let theme = theme else {
            return 0
        }

        let point = theme.point
        return ProgressCalculator(delegate: TotalProgressCalculatorDelegate()).getRecordPercent(point: point)
    }

    // MARK: - Private func

    private func handleData(data: Theme?) {
        theme = data

        if theme != nil {
            rootView?.updateTable()
            loadHeaderData()
        } else {
            rootView?.setEmptyStub()
        }
    }

    private func loadHeaderData() {
        guard let theme = theme else {
            return
        }

        let progressPercent = calculateTotalProgress()
        let levelDegree = LevelDegree.instanceByProgress(progressPercent: progressPercent)
        let progressLevel = ProgressLevel.defineLevel(progressPercent: progressPercent)

        rootView?.updateTableHeader(progressPercent: progressPercent, levelDegree: levelDegree, progressLevel: progressLevel)

        if theme.point.isEmpty() {
            rootView?.enableResetButton(isEnabled: false)
        }
    }

    private func getProgressValue(mode: Mode, point: Point) -> Int {
        return ProgressCalculator(mode: mode)?.getRecord(point: point) ?? 0
    }
}
