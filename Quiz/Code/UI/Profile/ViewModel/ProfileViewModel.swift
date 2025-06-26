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

@MainActor class ProfileViewModel: ObservableObject {
    
    private let loggerTag = "ProfileViewModel"
    
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var isWarning: Bool = false
    @Published var items: [ProfileItem] = []
    @Published var contentTitle: String?
    @Published var contentMode: ContentMode?
    
    @Published var isSorting: Bool = false
    @Published var isVibration: Bool = false
    @Published var isAiEnabled: Bool = false
    @Published var transition: String = ""
    @Published var aiConnection: String?
    
    @Published var navigationState: ProfileNavigationState? = nil

    // MARK: - Private Dependencies
    private let preferences: Preferences
    private let iapHelper: IAPHelperProtocol
    private let profileInteractor: ProfileInteractor
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private let aiConnectionClient: AiConnectionClient
    
    private let profileContentNotSelected = String(
        localized: "profile_title_content_not_selected",
        table: appLocalizable
    )
    
    private var aiConnectionModel: AiConnectionModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(
        preferences: Preferences,
        iapHelper: IAPHelperProtocol,
        profileInteractor: ProfileInteractor,
        contentInteractor: ContentInteractor,
        logger: Logger,
        aiConnectionClient: AiConnectionClient
    ) {
        self.preferences = preferences
        self.iapHelper = iapHelper
        self.profileInteractor = profileInteractor
        self.contentInteractor = contentInteractor
        self.logger = logger
        self.aiConnectionClient = aiConnectionClient
    }
    
    // MARK: - Public API
    
    func onAction(action: ProfileAction) {
        switch action {
        case .loadData:
            loadData()
        case .onProfileClicked(let item):
            onProfileItemClicked(item: item)
        case .onProfileItemChecked(let item, let isChecked):
            onProfileItemChecked(item: item, isChecked: isChecked)
        case .onRatePlatformClicked:
            onRatePlatformClicked()
        case .onReportBugPlatformClicked:
            onReportBugPlatformClicked()
        case .onNavigationHandled:
            onNavigationHandled()
        }
    }
    
    // MARK: - Private load data
    
    private func loadData() {
        getProfileData()
        getContentMode()
        subscribeToSelectedContent()
        subscribeToAiConnection()
    }
    
    private func getProfileData() {
        loadValues()
        self.items = profileInteractor.getData(
            aiEnabled: isAiEnabled,
            aiConnection: aiConnection
        )
    }

    private func loadValues() {
        self.isSorting = preferences.isSorting
        self.isVibration = preferences.isVibration
        self.isAiEnabled = preferences.isAiEnabled
        
        let pref = TransitionPreference.instance(value: preferences.transition)
        self.transition = pref?.title ?? ""
    }
    
    private func getContentMode() {
        let contentMode: ContentMode = IocContainer.app.resolve()
        self.contentMode = contentMode
    }
    
    private func subscribeToAiConnection() {
        aiConnectionClient
            .subscribeToCurrentAiConnection()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.logger.recordError(error: error)
                }
            } receiveValue: { [weak self] aiConnection in
                self?.processAiConnection(aiConnection: aiConnection)
            }
            .store(in: &cancellables)
    }
    
    private func processAiConnection(aiConnection: AiConnectionModel?) {
        if let name = aiConnection?.name {
            self.aiConnection = name
            self.aiConnectionModel = aiConnection
        } else {
            self.aiConnection = nil
            self.aiConnectionModel = nil
        }
        
        getProfileData()
    }
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.processContentError(error: error)
                }
            } receiveValue: { [weak self] content in
                self?.processContent(content: content)
            }
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContent(content: ContentModel?) {
        if let name = content?.name {
            contentTitle = name
        } else {
            contentTitle = profileContentNotSelected
        }
    }
    
    // MARK: - Private purchases
    
    private func restorePurchases() {
        isLoading = true
        
        iapHelper.restorePurchases { [weak self] isSuccess in
            Task { @MainActor in
                self?.isLoading = false
            }
        }
    }
    
    // MARK: - Private clicks
    
    private func onProfileItemChecked(item: ProfileItem, isChecked: Bool) {
        switch item.id {
        case .sortQuest:
            self.preferences.isSorting = isChecked
        case .vibration:
            self.preferences.isVibration = isChecked
        case .aiSwitcher:
            self.preferences.isAiEnabled = isChecked
        case .signAccount, .telegram, .pro, .supportProject, .restorePurchase,
             .rateApp, .shareFriend, .otherApps, .transition, .questTextSize,
             .answerTextSize, .reportError, .privacyPollicy, .selectContent, .openSource, .header,.sectionSocial,.sectionSettings, .sectionPleaseUs,.sectionFeedback, .aiConnection, .sectionAi:
            break
        }
        
        getProfileData()
    }
    
    private func onProfileItemClicked(item: ProfileItem) {
        switch item.id {
        case .telegram:
            self.navigationState = .navigateToTelegramChannel
        case .pro:
            self.navigationState = .navigateToProOnboarding
        case .restorePurchase:
            restorePurchases()
        case .rateApp:
            self.navigationState = .navigateToAppStore
        case .shareFriend:
            self.navigationState = .navigateToShare
        case .otherApps:
            self.navigationState = .navigateToOtherApps
        case .transition:
            self.navigationState = .navigateToTransition
        case .reportError:
            self.navigationState = .navigateToExternalReportError
        case .privacyPollicy:
            self.navigationState = .navigateToPrivacyPolicy
        case .selectContent:
            self.navigationState = .navigateToContents
        case .aiConnection:
            self.navigationState = .navigateToAiConnection(aiConnectionModel?.id)
        case .sortQuest, .vibration, .signAccount, .supportProject, .questTextSize,
                .answerTextSize, .openSource, .header,.sectionSocial,.sectionSettings,.sectionPleaseUs,.sectionFeedback, .aiSwitcher, .sectionAi:
            break
        }
    }
    
    private func onRatePlatformClicked() {
        self.navigationState = .navigateToExternalPlatformRate
    }
    
    private func onReportBugPlatformClicked() {
        self.navigationState = .navigateToExternalPlatformReportError
    }
    
    private func onNavigationHandled() {
        self.navigationState = nil
    }
}
