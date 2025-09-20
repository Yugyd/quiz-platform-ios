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
import SwiftUI

@MainActor class RecordEndViewModel: ObservableObject {
    
    private let loggerTag = "RecordEndViewModel"
    
    @Published var title: String? = nil
    @Published var subtitle: String? = nil
    @Published var buttonType: RecordEndActionMode = RecordEndActionMode.rate
    @Published var navigationState: RecordEndNavigationState?
    
    private var featureManager: FeatureManager
    private var remoteConfigRepository: RemoteConfigRepository
    private var mode: Mode
    private let logger: Logger
    
    private var isTelegramFeatureEnabled: Bool = false

    init(
        featureManager: FeatureManager,
             remoteConfigRepository: RemoteConfigRepository,
             mode: Mode,
        logger: Logger
    ) {
        self.featureManager = featureManager
        self.remoteConfigRepository = remoteConfigRepository
        self.mode = mode
        self.logger = logger

        onAction(action: .loadData)
    }
    
    func onAction(action:RecordEndAction) {
        switch action {
        case .loadData:
            loadData()
        case .onActionClicked:
            onActionClicked()
        case .onSkipClicked:
            onSkipClicked()
        case .onNavigationHandled:
            onNavigationHandled()
        }
    }
    
    private func onActionClicked() {
        switch buttonType {
        case .rate:
            navigationState = .navigateToRate
        case .telegram:
            navigationState = .navigateToTelegram
        }
        
    }
    
    private func onSkipClicked() {
        navigationState = .navigateToGameEnd
    }

    private func onNavigationHandled() {
        navigationState = nil
    }

    private func loadData() {
        isTelegramFeatureEnabled = featureManager.isFeatureEnabled(FeatureToggle.telegram)
        
        let config = remoteConfigRepository.fetchTelegramConfig()

        if isTelegramFeatureEnabled && config != nil {
            title = config!.gameEnd.title
            subtitle = config!.gameEnd.message
            buttonType = RecordEndActionMode.telegram(config!.gameEnd.buttonTitle.uppercased())
        } else {
            title = nil
            subtitle = nil
            buttonType = RecordEndActionMode.rate
        }
    }
}
