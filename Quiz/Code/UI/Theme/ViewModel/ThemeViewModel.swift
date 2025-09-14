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

@MainActor class ThemeViewModel: ObservableObject {
    
    nonisolated static let minSectionCountForStartScreen = 1
    
    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol
    
    private let loggerTag = "ThemeViewModel"
   
    @Published var isLoading: Bool = false
    @Published var isWarning: Bool = false
    @Published var items: [ThemeUiModel] = []
    @Published var selectedMode: Mode = .arcade  // Default mode (first index)
    @Published var showErrorMessage: Bool = false
    @Published var showInfoDialog: Theme? = nil
    @Published var navigationState: ThemeNavigationState?
    
    nonisolated private let contentRepository: ThemeSectionRepositoryProtocol
    nonisolated private let userRepository: PointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private var progressCalculator: ProgressCalculator?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        contentRepository: ThemeSectionRepositoryProtocol,
        userRepository: PointRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.logger = logger
    }
    
    func onAction(action: ThemeAction) {
        switch action {
        case .loadData:
            selectedMode = Mode.arcade
            progressCalculator = ProgressCalculator.init(mode: selectedMode)
            loadData()
        case .onGameModeChanged(let mode):
            onGameModeChanged(mode: mode)
        case .onStartClicked(let theme):
            startGame(theme: theme)
        case .onInfoClicked(let theme):
            showInfo(theme: theme)
        case .onInfoDialogDismissed:
            dismissInfoDialog()
        case .onErrorMessageDismissed:
            showErrorMessage = false
        case .onNavigationHandled:
            navigationState = nil
        }
    }
    
    private func onGameModeChanged(mode: Mode) {
        selectedMode = mode
        progressCalculator = ProgressCalculator.init(mode: mode)
        loadData()
    }
    
    private func loadData() {
        subscribeToSelectedContent()
    }
    
    private func subscribeToSelectedContent() {
        showLoading()
        
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error)
                    }
                },
                receiveValue: { [weak self] content in
                    self?.processContent(content)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(_ error: Error) {
        logger.recordError(error: error)
        
        showWarningState()
    }

    private func processContent(_ content: ContentModel?) {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                let mappedThemes = try await loadThemeData()
                
                if mappedThemes != nil && !mappedThemes!.isEmpty {
                    showDataState(data: mappedThemes!)
                } else {
                    showWarningState()
                }
            } catch {
                logger.recordError(error: error)

                showWarningState()
            }
        }
    }
    
    private func loadThemeData() async throws -> [ThemeUiModel]? {
        let data = try await self.contentRepository.getThemes()
        
        if data != nil {
            let themesWithPoints = try await self.userRepository.attachPoints(
                themes: data!
            )
            let mappedThemes = themesWithPoints.map { theme in
                let progressPercent = self.progressCalculator?.getRecordPercent(point: theme.point) ?? 0
                let progressLevel = ProgressLevel.defineLevel(progressPercent: progressPercent)
                
                return ThemeUiModel(
                    id: theme.id,
                    theme: theme,
                    progressPercent: progressPercent,
                    progressLevel: progressLevel
                )
            }
            
            return mappedThemes
        } else {
            return nil
        }
    }

    private func showLoading() {
        isLoading = true
        isWarning = false
        items = []
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
        items = []
    }
    
    private func showDataState(data: [ThemeUiModel]) {
        isLoading = false
        isWarning = false
        items = data
    }
    
    private func startGame(theme: Theme) {
        isLoading = true

        let gameMode = selectedMode
        
        Task { [weak self] in
            do {
                guard let self = self else {
                    return
                }
                
                let isSection = try await self.isContainSection(
                    gameMode: gameMode,
                    themeId: theme.id
                )
                
                processStartGame(gameMode: gameMode, theme: theme, isSection: isSection)
            } catch {
                self?.processStartGameError(error: error)
            }
        }
    }
    
    private func isContainSection(
        gameMode: Mode,
        themeId: Int
    ) async throws -> Bool {
        if gameMode == .arcade {
            let count = try await contentRepository.getSectionCount(theme: themeId) ?? 0
            return count >= ThemeViewModel.minSectionCountForStartScreen
        } else {
            return false
        }
    }
    
    private func processStartGame(gameMode: Mode, theme: Theme, isSection: Bool) {
        isLoading = false
        
        let record = progressCalculator?.getRecord(point: theme.point)
        
        let themeSenderArgs = ThemeSenderArgs(
            theme: theme,
            record: record,
            gameMode: gameMode

        )
        
        if isSection {
            navigationState = .navigateToSection(themeSenderArgs)
        } else {
            navigationState = .navigateToGame(themeSenderArgs)
        }
    }
    
    private func processStartGameError(error: Error) {
        logger.recordError(error: error)
        
        isLoading = false
        showErrorMessage = true
    }
    
    private func showInfo(theme: Theme) {
        showInfoDialog = theme
    }
    
    private func dismissInfoDialog() {
        showInfoDialog = nil
    }
}
