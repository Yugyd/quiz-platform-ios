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

import Foundation
import Combine
import SwiftUI

@MainActor class GameEndViewModel: ObservableObject {
    
    private let loggerTag = "GameEndViewModel"
    
    @Published var isLoading: Bool = false
    @Published var themeTitle: GameEndTitleState?
    @Published var progressPoint: String = ""
    @Published var progressCount: String = ""
    @Published var progressPercent: Int = 0
    @Published var progressLevel: ProgressLevel = .low
    @Published var isErrorsButtonVisible: Bool = false
    @Published var navigationState: GameEndNavigationState?
    
    private var contentRepository: ThemeRepositoryProtocol
    private var userRepository: ErrorRepositoryProtocol
    private let logger: Logger

    private var mode: Mode
    private var progressEnd: ProgressEnd
    private var isRewardedSuccess: Bool
    private var featureManager: FeatureManager

    init(
        contentRepository: ThemeRepositoryProtocol,
        userRepository: ErrorRepositoryProtocol,
        data: ProgressEnd,
        isRewardedOpen: Bool,
        logger: Logger,
        featureManager: FeatureManager
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.logger = logger

        self.mode = data.mode
        self.progressEnd = data

        self.isRewardedSuccess = isRewardedOpen
        
        self.featureManager = featureManager
    }
    
    func onAction(action: GameEndAction) {
        switch action {
        case .loadData:
            loadData()
        case .onNewGameClicked:
            onNewGameClicked()
        case .onShowErrorsClicked:
            onShowErrorsClicked()
        case .onNavigationHandled:
            onNavigationHandled()
        }
    }

    private func onNewGameClicked() {
        navigationState = .navigateToGame(mode, isRewardedSuccess)
    }
    
    private func onShowErrorsClicked() {
        navigationState = .navigateToErrorsList
    }

    private func onNavigationHandled() {
        navigationState = nil
    }
    
    func loadData() {
        Task {
            showLoading()
            
            let themeId = self.progressEnd.themeId!
            
            do {
                if let themeTitle = try await contentRepository.getThemeTitle(id: themeId) {
                    
                    let point = progressEnd.point
                    let count = progressEnd.count
                    
                    if self.progressEnd.mode == .error {
                        showData(
                            themeTitle: GameEndTitleState.error,
                            progressPoint: point,
                            progressCount: count,
                            progressPercent: Percent.calculatePercent(
                                value: point,
                                count: count
                            ),
                            errorQuestIds: progressEnd.errorQuestIds
                        )
                    } else {
                        let themeTitle = themeTitle
                        let progressCalculator = ProgressCalculator(mode: mode)

                        let stubProgressPercent = 0
                        let progressPercent = progressCalculator?.getRecordPercentByValue(value: point, count: count) ?? stubProgressPercent

                        showData(
                            themeTitle: GameEndTitleState.themeTitle(themeTitle),
                            progressPoint: point,
                            progressCount: count,
                            progressPercent: progressPercent,
                            errorQuestIds: progressEnd.errorQuestIds
                        )
                    }
                }
            } catch {
                logger.recordError(error: error)
            }
        }
    }
    
    private func showLoading() {
        self.isLoading = true
        self.themeTitle = nil
        self.progressPoint = ""
        self.progressCount = ""
        self.progressPercent = 0
    }
    
    private func showData(
        themeTitle: GameEndTitleState,
        progressPoint: Int,
        progressCount: Int,
        progressPercent: Int,
        errorQuestIds: Set<Int>?
    ) {
        self.isLoading = false
        self.themeTitle = themeTitle
        self.progressPoint = "\(progressPoint)"
        self.progressCount = "\(progressCount)"
        self.progressPercent = progressPercent
        self.progressLevel = ProgressLevel.defineLevel(progressPercent: progressPercent)
        self.isErrorsButtonVisible = errorQuestIds?.isEmpty == false
    }
}
