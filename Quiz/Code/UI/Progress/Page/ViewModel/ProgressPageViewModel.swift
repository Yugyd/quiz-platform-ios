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
import Combine

@MainActor class ProgressPageViewModel: ObservableObject {
    
    typealias ThemeQuestRepositoryProtocol = ThemeRepositoryProtocol & QuestRepositoryProtocol
    typealias PointResetRepositoryProtocol = ResetRepositoryProtocol & PointRepositoryProtocol
    
    private let defaultProgress = ProgressHeaderUiModel(
        progressPercent: 0,
        levelDegree: LevelDegree.schoolboy,
        progressLevel: ProgressLevel.low
    )
    
    @Published var isLoading: Bool = false
    @Published var isWarning: Bool = false
    @Published var items: [ProgressUiModel] = []
    @Published var header: ProgressHeaderUiModel = ProgressHeaderUiModel(
        progressPercent: 0,
        levelDegree: LevelDegree.schoolboy,
        progressLevel: ProgressLevel.low
    )
    @Published var isResetButtonEnabled: Bool = false
    @Published var navigationState: ProgressPageNavigationState?
    
    nonisolated private let contentRepository: ThemeQuestRepositoryProtocol
    nonisolated private let userRepository: ResetRepositoryProtocol & PointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private let themeId: Int
    private let updateCalback: ProgressUpdateCallback
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Internal State
    
    private var contentModel: ContentModel?
    private var theme: Theme?
    
    init(
        contentRepository: ThemeQuestRepositoryProtocol,
        userRepository: PointResetRepositoryProtocol,
        themeId: Int,
        contentInteractor: ContentInteractor,
        logger: Logger,
        updateCalback: ProgressUpdateCallback
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.logger = logger
        self.themeId = themeId
        self.updateCalback = updateCalback
    }
    
    // MARK: Public
    
    func onAction(action: ProgressPageAction) {
        switch action {
        case .loadData:
            loadData()
        case .onResetClicked:
            onResetClicked()
        case .onNavigationHandled:
            navigationState = nil
        }
    }
    
    // MARK: Private load content
    
    private func loadData() {
        loadProgressData()
        
        subscribeToSelectedContent()
    }
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .map { [weak self] newModel in
                guard let self else {
                    return ContentResult(isBack: false, newModel: newModel)
                }
                
                return self.contentInteractor.isResetNavigation(
                    oldModel: self.contentModel,
                    newModel: newModel
                )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.processContentResetEvent(model: result)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(_ error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContentResetEvent(model: ContentResult) {
        self.contentModel = model.newModel
        
        if model.isBack {
            self.navigationState = .back
        }
    }
    
    // MARK: Private load progress
    
    private func loadProgressData() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                showLoading()
                
                let result = try await loadProgressItems(themeId: themeId)
                
                let mappedThemes = result?.items
                let header = result?.header
                let theme = result?.themeData
                
                if mappedThemes != nil && !mappedThemes!.isEmpty && header != nil && theme != nil {
                    showDataState(
                        theme: theme!,
                        header: header!,
                        data: mappedThemes!
                    )
                } else {
                    showWarningState()
                }
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
   
    private func loadProgressItems(themeId: Int) async throws -> ProgressPageResult? {
        let theme = try await self.contentRepository.getTheme(id: themeId)
        
        let themeWithPoint = try await self.userRepository.attachPoints(
            themes: [theme!]
        ).first
        
        if themeWithPoint != nil {
            let progressModes: [Mode] = [.arcade, .marathon, .sprint]
            let mappedThemes = progressModes.map { mode in
                let progressPercent = calculateProgress(
                    mode: mode,
                    point: themeWithPoint!.point
                )
                
                let progressLevel = ProgressLevel.defineLevel(
                    progressPercent: progressPercent
                )
                
                let progressTint = ProgressColor.getColor(
                    level: progressLevel
                )
                
                let subtitle = getProgressTitle(
                    mode: mode,
                    point: themeWithPoint!.point
                )
                
                return ProgressUiModel(
                    id: mode.title.hashValue,
                    title: mode.title,
                    subtitle: subtitle,
                    value: "\(progressPercent)",
                    progressColor: progressTint
                )
            }
            
            let header = loadHeader(
                theme: themeWithPoint!
            )
            
            return ProgressPageResult(
                themeData: themeWithPoint!,
                items: mappedThemes,
                header: header
            )
        } else {
            return nil
        }
    }
    
    private func loadHeader(theme: Theme) -> ProgressHeaderUiModel {
        let totalProgressPercent = calculateTotalProgress(theme: theme)
        let totalProgressLevel = ProgressLevel.defineLevel(
            progressPercent: totalProgressPercent
        )
        let totalLevelDegree = LevelDegree.instanceByProgress(
            progressPercent: totalProgressPercent
        )
        
        return ProgressHeaderUiModel(
            progressPercent: totalProgressPercent,
            levelDegree: totalLevelDegree,
            progressLevel: totalProgressLevel
        )
    }
    
    private func getProgressTitle(mode: Mode, point: Point) -> String {
        let progressValue = getProgressValue(mode: mode, point: point)
        
        let count: Int
        if mode == .sprint {
            count = Record.sprintRecordMax
        } else {
            count = point.count
        }
        
        let outOf = String(
            localized: "design_system_format_record_progress",
            table: appLocalizable
        )
        return "\(progressValue)\(outOf)\(count)"
    }
    
    private func getProgressValue(mode: Mode, point: Point) -> Int {
        return ProgressCalculator(mode: mode)?.getRecord(point: point) ?? 0
    }
    
    private func calculateProgress(mode: Mode, point: Point) -> Int {
        return ProgressCalculator(
            mode: mode
        )?.getRecordPercent(point: point) ?? 0
    }
    
    private func calculateTotalProgress(theme: Theme) -> Int {
        let point = theme.point
        
        return ProgressCalculator(
            delegate: TotalProgressCalculatorDelegate()
        ).getRecordPercent(point: point)
    }
    
    // MARK: Private state funcs
    
    private func showLoading() {
        isLoading = true
        isWarning = false
        header = defaultProgress
        theme = nil
        items = []
        isResetButtonEnabled = false
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
        header = defaultProgress
        theme = nil
        items = []
        isResetButtonEnabled = false
    }
    
    private func showDataState(
        theme: Theme,
        header: ProgressHeaderUiModel,
        data: [ProgressUiModel]
    ) {
        isLoading = false
        isWarning = false
        self.header = header
        self.theme = theme
        items = data
        isResetButtonEnabled = !theme.point.isEmpty()
    }
    
    // MARK: Private actions
    
    private func onResetClicked() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                isLoading = true
                
                let isReset = try await reset(theme: theme)
                
                processReset(isReset: isReset)
                
                isLoading = false
            } catch {
                logger.recordError(error: error)
                
                isLoading = false
            }
        }
    }
    
    // MARK: - Private reset
    
    private func reset(theme: Theme?) async throws -> Bool {
        guard let theme = theme else {
            return false
        }
        
        let questIds = try await contentRepository.getQuestIds(theme: theme.id, isSort: false)
        _ = try await userRepository.resetSectionProgress(questIds: questIds)
        
        let isReset = try await userRepository.resetThemeProgress(theme: theme.id)
        
        return isReset
    }
    
    private func processReset(isReset: Bool) {
        if isReset {
            loadProgressData()
            updateCalback.update()
        }
        
        isResetButtonEnabled = !isReset
    }
    
    // MARK: Models
    
    struct ProgressPageResult {
        let themeData: Theme
        let items: [ProgressUiModel]
        let header: ProgressHeaderUiModel
    }
}
