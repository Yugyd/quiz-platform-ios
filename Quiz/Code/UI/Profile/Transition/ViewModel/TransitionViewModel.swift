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

@MainActor class TransitionViewModel: ObservableObject {
    
    private let loggerTag = "TransactionViewModel"
    
    @Published var items: [TransitionUiModel] = []
    @Published var isLoading: Bool = false
    @Published var isWarning: Bool = false
    @Published var navigationState: TransactionNavigationState?
    
    private let transitionInteractor: TransitionInteractor
    private let logger: Logger
    
    init(
        transitionInteractor: TransitionInteractor,
        logger: Logger
    ) {
        self.transitionInteractor = transitionInteractor
        self.logger = logger
    }
    
    // MARK: Public func
    
    func onAction(action: TransactionAction) {
        switch action {
        case .loadData:
            loadData()
        case .onTransitionClicked(let transition):
            onTransitionClicked(model: transition)
        case .onNavigationHandled:
            navigationState = nil
        }
    }
    
    // MARK: Private func
    
    private func onTransitionClicked(model: TransitionUiModel) {
        isLoading = true
        
        Task {
            do {
                try await transitionInteractor.setPreferencesValue(value: model.value)
                loadData()
                
                navigationState = .back
                isLoading = false
            } catch {
                logger.recordError(error: error)
                
                isLoading = false
            }
        }
    }
    
    private func loadData() {
        showLoading()
        
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                let data = try await loadValues()
                showDataState(data: data)
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
    
    private func loadValues() async throws -> [TransitionUiModel] {
        let currentTransition = try await transitionInteractor.getCurrentItemByPreferencesValue()
        
        return transitionInteractor
            .loadData()
            .enumerated()
            .map { (transactionIndex, transaction) in
                return TransitionUiModel(
                    id: "\(transaction)",
                    value: transaction,
                    isChecked: transaction == currentTransition
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
    
    private func showDataState(data: [TransitionUiModel]) {
        isLoading = false
        isWarning = false
        items = data
    }
}
