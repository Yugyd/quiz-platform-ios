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

import Combine
import Foundation

@MainActor class ProgressPagePresenter: ProgressPagePresenterProtocol {
    
    typealias ThemeQuestRepositoryProtocol = ThemeRepositoryProtocol & QuestRepositoryProtocol
    typealias PointResetRepositoryProtocol = ResetRepositoryProtocol & PointRepositoryProtocol
    
    var themeId: Int
    var theme: Theme?
    var contentModel: ContentModel?
    var modes: [Mode] = [.arcade, .marathon, .sprint]
    
    weak fileprivate var rootView: ProgressPageViewProtocol?
    
    nonisolated private let contentRepository: ThemeQuestRepositoryProtocol
    nonisolated private let userRepository: ResetRepositoryProtocol & PointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        contentRepository: ThemeQuestRepositoryProtocol,
        userRepository: PointResetRepositoryProtocol,
        themeId: Int,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.themeId = themeId
        self.contentInteractor = contentInteractor
        self.logger = logger
    }
    
    func attachView(rootView: ProgressPageViewProtocol) {
        self.rootView = rootView
    }
    
    func loadData() {
        loadProgressData()
        
        subscribeToSelectedContent()
    }
    
    func resetProgress() {
        Task {
            let isReset = await reset(theme: theme)
            processReset(isReset: isReset)
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
    
    // MARK: - Private selected content
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .map { newModel in
                self.contentInteractor.isResetNavigation(
                    oldModel: self.contentModel,
                    newModel: newModel
                )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error: error)
                    }
                },
                receiveValue: { [weak self] contentResult in
                    self?.processContentResetEvent(model: contentResult)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContentResetEvent(model: ContentResult) {
        if (model.isBack) {
            rootView?.onBack()
        }
        
        self.contentModel = model.newModel
    }
    
    // MARK: - Private load progress data
    
    private func loadProgressData() {
        Task {
            let result = await loadProgressData(themeId: themeId)
            handleData(data: result)
        }
    }
    
    private func loadProgressData(themeId: Int) async -> Theme? {
        return await withUnsafeContinuation { continuation in
            DispatchQueue.global().async { [weak self] in
                var result: [Theme]?
                
                if let self = self {
                    let data = self.contentRepository.getTheme(id: themeId)
                    
                    if let data = data {
                        result = self.userRepository.attachPoints(themes: [data])
                    }
                    let theme = result?[0] ?? nil
                    continuation.resume(returning: theme)
                }
            }
        }
    }
    
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
    
    // MARK: - Private reset
    
    private func reset(theme: Theme?) async -> Bool {
        return await withUnsafeContinuation { continuation in
            DispatchQueue.global().async { [weak self] in
                guard let theme = theme else {
                    return
                }
                
                let questIds = self?.contentRepository.getQuestIds(theme: theme.id, isSort: false)
                _ = self?.userRepository.resetSectionProgress(questIds: questIds)
                
                let isReset = self?.userRepository.resetThemeProgress(theme: theme.id) ?? false
                continuation.resume(returning: isReset)
            }
        }
    }
    
    private func processReset(isReset: Bool) {
        if isReset {
            loadProgressData()
            rootView?.updateCallback?.update()
        }
        
        rootView?.enableResetButton(isEnabled: !isReset)
    }
}
