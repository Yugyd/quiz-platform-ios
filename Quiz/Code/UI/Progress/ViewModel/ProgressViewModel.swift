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
import SwiftUICore

@MainActor class ProgressViewModel: ObservableObject {
    
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
    @Published var navigationState: ProgressNavigationState?
    
    private let contentRepository: ThemeRepositoryProtocol
    private let userRepository: PointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private var progressCalculator: ProgressCalculator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        contentRepository: ThemeRepositoryProtocol,
        userRepository: PointRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.logger = logger
        self.progressCalculator = ProgressCalculator(
            delegate: TotalProgressCalculatorDelegate()
        )
    }
    
    // MARK: Public
    
    func onAction(action: ProgressAction) {
        switch action {
        case .loadData:
            loadData()
        case .onProgressClicked(item: let item):
            onProgressClicked(item: item)
        case .onNavigationHandled:
            navigationState = nil
        }
    }
    
    // MARK: Private load content
    
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
                let result = try await loadProgressData()
                let mappedThemes = result?.items
                let header = result?.header
                
                if mappedThemes != nil && !mappedThemes!.isEmpty && header != nil {
                    showDataState(
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
    
    // MARK: Private load progress
    
    private func loadProgressData() async throws -> ProgressResult? {
        let data = try await self.contentRepository.getThemes()
        
        if data != nil {
            let themesWithPoints = try await self.userRepository.attachPoints(
                themes: data!
            )
            
            let mappedThemes = themesWithPoints.map { theme in
                let progressPercent = self.progressCalculator.getRecordPercent(point: theme.point)
                let progressLevel = ProgressLevel.defineLevel(progressPercent: progressPercent)
                let levelDegree = LevelDegree.instanceByProgress(progressPercent: progressPercent)
                
                let progressTint = ProgressColor.getColor(
                    level: progressLevel
                )
                
                return ProgressUiModel(
                    id: theme.id,
                    title: theme.name,
                    subtitle: LevelDegree.getTitle(levelDegree: levelDegree),
                    value: "\(progressPercent)",
                    progressColor: progressTint
                )
            }
            
            let header = loadHeader(themesWithPoints: themesWithPoints)
            
            return ProgressResult(
                items: mappedThemes,
                header: header
            )
        } else {
            return nil
        }
    }
    
    private func loadHeader(themesWithPoints: [Theme]) -> ProgressHeaderUiModel {
        let totalProgressPercent = calculateTotalProgress(items: themesWithPoints)
        let totalProgressLevel = ProgressLevel.defineLevel(progressPercent: totalProgressPercent)
        let totalLevelDegree = LevelDegree.instanceByProgress(progressPercent: totalProgressPercent)
        return ProgressHeaderUiModel(
            progressPercent: totalProgressPercent,
            levelDegree: totalLevelDegree,
            progressLevel: totalProgressLevel
        )
    }
    
    private func calculateTotalProgress(items: [Theme]) -> Int {
        var total = 0
        for theme in items {
            total += progressCalculator.getRecordPercent(point: theme.point)
        }
        return total / items.count
    }
    
    // MARK: Private state funcs
    
    private func showLoading() {
        isLoading = true
        isWarning = false
        header = defaultProgress
        items = []
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
        header = defaultProgress
        items = []
    }
    
    private func showDataState(
        header: ProgressHeaderUiModel,
        data: [ProgressUiModel]
    ) {
        isLoading = false
        isWarning = false
        self.header = header
        items = data
    }
    
    // MARK: Private actions
    
    private func onProgressClicked(item: ProgressUiModel) {
        navigationState = .navigateToSpecificProgress(item)
    }
    
    // MARK: Models
    
    struct ProgressResult {
        let items: [ProgressUiModel]
        let header: ProgressHeaderUiModel
    }
}
