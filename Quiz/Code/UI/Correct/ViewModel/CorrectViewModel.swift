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

@MainActor class CorrectViewModel: ObservableObject {
    
    private let loggerTag = "CorrectViewModel"
    
    @Published var isStartButtonEnabled: Bool = false
    @Published var availableMode: CorrectAvailableMode = .none
    @Published var isEmptyStubVisible: Bool = false
    @Published var navigationState: CorrectNavigationState?
    @Published var showErrorMessage: Bool = false

    private let repository: ErrorRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    private let contentMode: ContentMode

    private var cancellables = Set<AnyCancellable>()

    init(
        repository: ErrorRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger,
        contentMode: ContentMode = IocContainer.app.resolve()
    ) {
        self.repository = repository
        self.contentInteractor = contentInteractor
        self.logger = logger
        self.contentMode = contentMode

        onAction(action: .loadData)
    }
    
    func onAction(action:CorrectAction) {
        switch action {
        case .loadData:
            loadData()
        case .onErrorMessageDismissed:
            onErrorDismissed()
        case .onNavigationHandled:
            onNavigationHandled()
        case .onStartClicked:
            onStartClicked()
        }
    }
    
    private func onStartClicked() {
        navigationState = .navigateToGame
    }

    private func onErrorDismissed() {
        showErrorMessage = false
    }

    private func onNavigationHandled() {
        navigationState = nil
    }

    private func loadData() {
        subscribeToSelectedContent()
    }
    
    private func subscribeToSelectedContent() {
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
        
        showErrorMessage = true
    }

    private func processContent(_ content: ContentModel?) {
        Task {
            do {
                let hasErrors = try await repository.isHaveErrors()
                handleData(hasErrors)
            } catch {
                logger.recordError(error: error)

                showErrorMessage = true
            }
        }
    }

    private func handleData(_ hasErrors: Bool?) {
        guard let hasErrors = hasErrors else {
            isEmptyStubVisible = true
            return
        }

        isEmptyStubVisible = false

        if contentMode == .pro {
            availableMode = .gameButton
            isStartButtonEnabled = hasErrors
        } else {
            availableMode = .proMessage
        }
    }
    
}
