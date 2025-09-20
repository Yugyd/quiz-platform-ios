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

@MainActor class ErrorViewModel: ObservableObject {
    
    private let loggerTag = "ErrorViewModel"
    
    @Published var items: [ErrorQuest] = []
    @Published var isLoading: Bool = false
    @Published var isWarning: Bool = false
    @Published var showErrorMessage: Bool = false
    @Published var navigationState: ErrorNavigationState?
    
    private let repository: QuestRepositoryProtocol
    private let aiTasksInteractor: AiTasksInteractor
    private let questFormatter: SymbolFormatter // Line separtor formatter
    private let logger: Logger
    private let args: ErrorsInitialArgs
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        repository: QuestRepositoryProtocol,
        aiTasksInteractor: AiTasksInteractor,
        questFormatter: SymbolFormatter,
        initialArgs: ErrorsInitialArgs,
        logger: Logger
    ) {
        self.repository = repository
        self.aiTasksInteractor = aiTasksInteractor
        self.questFormatter = questFormatter
        self.args = initialArgs
        self.logger = logger
        
        onAction(.loadData)
    }
    
    func onAction(_ action: ErrorListAction) {
        switch action {
        case .loadData:
            loadData()
        case let .onItemClicked(item):
            navigationState = .navigateToBrowser(item)
        case let .onFavoriteClicked(item):
            toggleFavorite(item: item)
        case .onErrorMessageDismissed:
            showErrorMessage = false
        case .onNavigationHandled:
            navigationState = nil
        }
    }

    private func loadData() {
        showLoading()
        
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            guard !self.args.errorIds.isEmpty else {
                showWarningState()
                return
            }
            
            do {
                let data: [ErrorQuest]?
                switch args.mode {
                case .aiTasks:
                    data = await getAiTasks()
                case .arcade,.marathon,.sprint,.error, .unused:
                    data = try await self.repository.getErrors(ids: args.errorIds)
                case nil:
                    fatalError("Unsupported mode")
                }
                                
                if data != nil {
                    let mappedData = data!.map {
                        return ErrorQuest(id: $0.id, quest: self.questFormatter.format(data: $0.quest), trueAnswer: $0.trueAnswer)
                    }
                    
                    showDataState(data: mappedData)
                } else {
                    showWarningState()
                }
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
    
    private func getAiTasks() async -> [ErrorQuest]? {
        guard args.aiThemeId != nil else {
            return nil
        }
        
        return aiTasksInteractor
            .getAiTasks(aiThemeId: args.aiThemeId!)
            .filter { aiTask in
                args.errorIds.contains(aiTask.id)
            }
            .map { aiTask in
                ErrorQuest(
                    id: aiTask.id,
                    quest: aiTask.quest,
                    trueAnswer: aiTask.trueAnswer
                )
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
    
    private func showDataState(data: [ErrorQuest]) {
        isLoading = false
        isWarning = false
        items = data
    }
    
    private func toggleFavorite(item: ErrorQuest) {
        // Add support tasks feature
    }
}
