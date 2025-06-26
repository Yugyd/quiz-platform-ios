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
import UIKit

@MainActor
final class SectionViewModel: ObservableObject {
    
    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol
    
    private let loggerTag = "SectionViewModel"
    
    @Published var isLoading: Bool = true
    @Published var isWarning: Bool = false
    @Published var items: [SectionUiModel] = []
    @Published var themeTitle: String = ""
    @Published var theme: Theme? = nil
    @Published var navigationState: SectionNavigationState? = nil
    
    private let contentRepository: ThemeSectionRepositoryProtocol
    private let userRepository: SectionPointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private let themeId: Int
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Internal State
    
    private var contentModel: ContentModel?
        
    init(
        contentRepository: ThemeSectionRepositoryProtocol,
        userRepository: SectionPointRepositoryProtocol,
        themeId: Int,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.themeId = themeId
        self.logger = logger
    }
    
    // MARK: - Public API
    func onAction(action: SectionAction) {
        switch action {
        case .loadData:
            loadData()
        case .onSectionClicked(let section):
            onSectionClicked(section: section)
        case .onNavigationHandled:
            navigationState = nil
        }
    }
    
    // MARK: - Private
    
    func onSectionClicked(section: SectionUiModel) {
        guard let theme = theme else {
            return
        }
        
        switch section.positionState {
        case .below, .latest:
            navigationState = .navigateToGame(
                SectionSenderArgs(
                    theme: theme,
                    section: section.item.item
                 )
            )
        case .above:
            return
        }
    }
    
    func onNavigationHandled() {
        navigationState = nil
    }
    
    private func loadData() {
        loadSectionData()
        subscribeToSelectedContent()
    }
    
    // MARK: - Private load sections

    private func loadSectionData() {
        Task {  [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                showLoading()
                
                let result = try await loadSections(themeId: themeId)
                
                guard let result = result else {
                    showWarningState()
                    return
                }
                
                showDataState(
                    theme: result.themeData,
                    data: result.sectionsData
                )
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
    
    private func loadSections(themeId: Int) async throws -> ContentAndResult? {
        let theme = try await contentRepository.getTheme(id: themeId)
        let rawSections = try await contentRepository.getSections(theme: themeId)
        let enrichedSections = try await userRepository.attachPoints(sections: rawSections ?? [])
        
        guard let theme = theme else {
            return nil
        }
        
        let sectionWithLevelItems = enrichedSections.map { section in
            let percent = Percent.calculatePercent(
                value: section.point ?? 0,
                count: section.count
            )
            return SectionWithLevel(
                item: section,
                level: SectionLevel.defineLevel(progressPercent: percent)
            )
        }
        
        let latestSectionId = sectionWithLevelItems.first(where: {
            $0.level == .empty || $0.level == .low
        })?.item.id
        
        let sectionUiModels = sectionWithLevelItems.map { sectionWithLevel in
            return SectionUiModel(
                id: sectionWithLevel.item.id,
                item: sectionWithLevel,
                positionState: isLatestSection(
                    id: sectionWithLevel.item.id,
                    latestSectionId: latestSectionId
                )
            )
        }
        
        if sectionUiModels.isEmpty {
            return nil
        }
        
        return ContentAndResult(
            themeData: theme,
            sectionsData: sectionUiModels
        )
    }
    
    func isLatestSection(
        id: Int,
        latestSectionId: Int?
    ) -> SectionPositionState {
        guard let latestSectionId = latestSectionId else {
            return SectionPositionState.below
        }
        
        // section ids are always arranger in order
        if id < latestSectionId {
            return SectionPositionState.below
        } else if id > latestSectionId {
            return SectionPositionState.above
        } else {
            return SectionPositionState.latest
        }
    }
    
    private func showLoading() {
        isLoading = true
        isWarning = false
        items = []
        themeTitle = ""
        theme = nil
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
        items = []
        themeTitle = ""
        theme = nil
    }
    
    private func showDataState(
        theme: Theme,
        data: [SectionUiModel]
    ) {
        isLoading = false
        isWarning = false
        items = data
        self.themeTitle = theme.name
        self.theme = theme
    }
    
    // MARK: - Private load selected content

    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .map { [weak self] newModel in
                guard let self else { return ContentResult(isBack: false, newModel: newModel) }
                return self.contentInteractor.isResetNavigation(oldModel: self.contentModel, newModel: newModel)
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error: error)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.processContentResetEvent(model: result)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
        
        showWarningState()
    }
    
    private func processContentResetEvent(model: ContentResult) {
        self.contentModel = model.newModel
        
        if model.isBack {
            self.navigationState = .back
        }
    }
    
    // MARK: - Structs
    
    private struct ContentAndResult {
        let themeData: Theme
        let sectionsData: [SectionUiModel]
    }
}
