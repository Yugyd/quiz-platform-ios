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

@MainActor
class AiConnectionDetailsViewModel: ObservableObject {
    private let loggerTag = "AiConnectionDetailsViewModel"
    
    // MARK: - Published State
    @Published var isWarning: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorMessage: AiConnectionDetailsSnackbarMessage? = nil
    
    @Published var domainState: AiConnectionDetailsDomainState = AiConnectionDetailsDomainState()
    @Published var toolbarTitle: AiConnectionDetailsToolbarTitle? = nil
    @Published var keyInstructionLink: String? = nil

    @Published var name: String = ""
    @Published var selectedProvider: String = ""
    @Published var allProviders: [String] = []
    @Published var isProviderEnabled: Bool = true
    @Published var apiKey: String = ""
    @Published var isApiKeyValid: Bool? = nil
    @Published var cloudProjectFolder: String = ""
    @Published var isCloudProjectFolderVisible: Bool = false
    @Published var isSaveButtonEnabled: Bool = true
    @Published var isDeleteVisible: Bool = false

    @Published var navigationState: AiConnectionDetailsNavigationState? = nil
    
    // MARK: - Dependencies
    private let aiConnectionClient: AiConnectionClient
    private let aiRemoteConfigSource: AiRemoteConfigSource
    private let logger: Logger

    // MARK: - Internal State
    private var isEditMode: Bool = false
    private var aiConnectionId: String? = nil
    private var aiProviders: [AiConnectionProviderModel] = []
    private var aiInstructionConfigs: [AiInstructionConfig] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        aiConnectionClient: AiConnectionClient,
        aiRemoteConfigSource: AiRemoteConfigSource,
        logger: Logger,
        aiConnectionId: String? = nil
    ) {
        self.aiConnectionClient = aiConnectionClient
        self.aiRemoteConfigSource = aiRemoteConfigSource
        self.aiConnectionId = aiConnectionId
        self.logger = logger

        self.isEditMode = aiConnectionId != nil
        self.toolbarTitle = isEditMode ? .edit : .add
        self.isDeleteVisible = isEditMode
    }
    
    // MARK: - Action handler
    func onAction(_ action: AiConnectionDetailsAction) {
        switch action {
        case .loadData:
            loadData()
        case .onKeyInstructionClicked:
            handleKeyInstructionClicked()
        case .onSaveClicked:
            handleSaveClicked()
        case .onDeleteClicked:
            handleDeleteClicked()
        case let .onNameChanged(name):
            handleNameChanged(name)
        case let .onProviderSelected(provider):
            handleProviderSelected(provider)
        case let .onApiKeyChanged(apiKey):
            handleApiKeyChanged(apiKey)
        case let .onCloudProjectFolderChanged(folder):
            handleCloudProjectFolderChanged(folder)
        case .onSnackbarDismissed:
            handleSnackbarDismissed()
        case .onNavigationHandled:
            handleNavigationHandled()
        case .onBackPressed:
            handleBackPressed()
        }
    }
    
    // MARK: - Load data
    
    private func loadData() {
        Task { [weak self] in
            guard let self = self else { return }
            
            self.showLoading()
            self.domainState = AiConnectionDetailsDomainState(aiConnectionModel: nil, apiKeyAiInstructionConfigs: nil)
            
            do {
                // Providers
                let providers = try await aiConnectionClient.getAvailableAiProviders()
                
                // Instructions
                let instructionConfigs = await aiRemoteConfigSource.getAiInstructionConfigs()
                
                // Model (edit mode)
                let aiConnection: AiConnectionModel? = isEditMode
                 ? try await aiConnectionClient.getAiConnection()
                 : nil
                
                processLoadData(
                    providers: providers,
                    instructionConfigs: instructionConfigs,
                    aiConnection: aiConnection
                )
            } catch {
                logger.logError(error: error)
                
                self.showWarning()
            }
        }
    }
    
    private func processLoadData(
        providers: [AiConnectionProviderModel],
        instructionConfigs: [AiInstructionConfig],
        aiConnection: AiConnectionModel?
    ) {
        if let aiConnection = aiConnection {
            self.name = aiConnection.name
            self.selectedProvider = providers.first(where: { $0.type == aiConnection.apiProvider })?.name ?? ""
            self.apiKey = aiConnection.apiKey
            self.cloudProjectFolder = aiConnection.apiCloudFolder ?? ""
            self.isCloudProjectFolderVisible = aiConnection.apiProvider.isNeedFolder
            self.isProviderEnabled = false
        } else {
            let firstProvider = providers.first
            self.selectedProvider = firstProvider?.name ?? ""
            self.isCloudProjectFolderVisible = firstProvider?.type.isNeedFolder ?? false
            self.isProviderEnabled = true
        }
        
        self.aiProviders = providers
        self.allProviders = providers.map { $0.name }
        
        handleProviderSelected(selectedProvider)

        self.aiInstructionConfigs = instructionConfigs

        self.domainState = AiConnectionDetailsDomainState(
            aiConnectionModel: aiConnection,
            apiKeyAiInstructionConfigs: instructionConfigs
        )
        
        self.processData()
    }
    
    // MARK: - Private Action Handlers
    
    private func handleKeyInstructionClicked() {
        guard let providerType = aiProviders.first(where: { $0.name == selectedProvider })?.type else { return }
        
        if let url = aiInstructionConfigs.first(where: { $0.id == providerType })?.url {
            navigationState = .navigateToExternalBrowser(url)
        } else {
            logger.print(tag: loggerTag, message: "AI instruction link not found for provider: \(selectedProvider)")
        }
    }
    
    private func handleSaveClicked() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !selectedProvider.isEmpty,
              !apiKey.trimmingCharacters(in: .whitespaces).isEmpty,
              !(isCloudProjectFolderVisible && cloudProjectFolder.trimmingCharacters(in: .whitespaces).isEmpty)
        else {
            showErrorMessage = .fillFields
            return
        }

        self.saveAiConnection()
    }
    
    private func saveAiConnection() {
        Task { [weak self] in
            guard let self else { return }
            
            self.isLoading = true
            
            do {
                let providerType = self.aiProviders.first(where: { $0.name == self.selectedProvider })?.type ?? .none
                let aiModel = UpdateAiConnectionModel(
                    name: self.name,
                    apiProvider: providerType,
                    apiKey: self.apiKey,
                    apiCloudFolder: self.isCloudProjectFolderVisible ? self.cloudProjectFolder : nil
                )
                
                if self.isEditMode {
                    // Update
                    let result = await aiConnectionClient.updateAiConnection(model: aiModel)
                    
                    self.isLoading = false
                    if result {
                        self.navigationState = .back
                    } else {
                        self.showErrorMessage = .error
                    }
                } else {
                    // Add
                    let result = await aiConnectionClient.addAiConnection(model: aiModel)
                    
                    self.isLoading = false
                    if result {
                        self.navigationState = .back
                    } else {
                        self.showErrorMessage = .error
                    }
                }
            } catch {
                logger.logError(error: error)
                
                self.isLoading = false
                self.showErrorMessage = .error
            }
        }
    }
    
    private func handleDeleteClicked() {
        guard isEditMode else { return }
        
        deleteAiConnection()
    }
    
    private func deleteAiConnection() {
        Task { [weak self] in
            guard let self else { return }
            
            self.isLoading = true
            
            do {
                let result = await aiConnectionClient.deleteAiConnection()
                
                self.isLoading = false
                if result {
                    self.navigationState = .back
                } else {
                    self.showErrorMessage = .error
                }
            } catch {
                logger.logError(error: error)
                
                self.isLoading = false
                self.showErrorMessage = .error
            }
        }
    }
    
    private func handleNameChanged(_ name: String) {
        self.name = name
    }
    
    private func handleProviderSelected(_ provider: String) {
        self.selectedProvider = provider
        
        guard let type = aiProviders.first(where: { $0.name == provider })?.type else {
            isCloudProjectFolderVisible = false
            return
        }
        
        isCloudProjectFolderVisible = type.isNeedFolder
    }
    
    private func handleApiKeyChanged(_ apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func handleCloudProjectFolderChanged(_ folder: String) {
        self.cloudProjectFolder = folder
    }
    
    private func handleSnackbarDismissed() {
        showErrorMessage = nil
    }
    
    private func handleNavigationHandled() {
        navigationState = nil
    }
    
    private func handleBackPressed() {
        navigationState = .back
    }
    
    // MARK: - Private State Handlers

    private func showLoading() {
        isLoading = true
        isWarning = false
    }
    
    private func showWarning() {
        isLoading = false
        isWarning = true
    }
    
    private func processData() {
        isLoading = false
        isWarning = false
    }
}
