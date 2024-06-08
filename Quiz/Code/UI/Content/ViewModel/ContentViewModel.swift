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

@MainActor class ContentViewModel: ObservableObject {
    private let loggerTag = "ContentViewModel"
    
    private(set) var isBackEnabled: Bool
    
    @Published var items: [ContentModel] = []
    @Published private(set) var isWarning: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: ErrorMessageState? = nil
    @Published var startFileProvider: Bool = false
    @Published var navigationState: NavigationState? = nil
    
    private let interactor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        interactor: ContentInteractor,
        logger: Logger,
        isBackEnabled: Bool
    ) {
        self.interactor = interactor
        self.logger = logger
        self.isBackEnabled = isBackEnabled
        
        onAction(action: .loadData)
    }
    
    func onAction(action: Action) {
        switch action {
        case .loadData:
            loadData()
        case let .onItemClicked(item):
            onItemClicked(item: item)
        case let .onDeleteClicked(item):
            onDeleteClicked(item: item)
        case .onOpenFileClicked:
            onOpenFileClicked()
        case .onContentFormatClicked:
            onContentFormatClicked()
        case .onErrorMessageDismissed:
            errorMessage = nil
        case .onOpenFileProviderHandled:
            onOpenFileHandled()
        case .onDocumentResult(uri: let uri):
            onDocumentResult(uri: uri)
        case .onDocumentResultError(error: let error):
            onDocumentResultError(error: error)
        case .onNavigationHandled:
            onNavigationHandled()
        }
    }
    
    private func loadData() {
        logger.print(
            tag: loggerTag,
            message: "Load data"
        )
        
        showLoading()
        
        interactor
            .subscribeToContents()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processDataError(error: error)
                    }
                },
                receiveValue: { [weak self] models in
                    self?.processData(newItems: models)
                }
            )
            .store(in: &cancellables)
    }
    
    private func showLoading() {
        isLoading = true
        isWarning = false
        items = []
    }
    
    private func processDataError(error: Error) {
        logger.recordError(error: error)
        
        isLoading = false
        isWarning = true
        items = []
    }
    
    private func processData(newItems: [ContentModel]) {
        isLoading = false
        isWarning = false
        items = newItems
    }
    
    private func onItemClicked(item: ContentModel) {
        logger.print(
            tag: loggerTag,
            message: "Item clicked \(item)"
        )
        
        guard let selectedItem = items.first(where: { $0.isChecked }) else {
            return
        }
        
        if item == selectedItem {
            return
        }
        
        Task {
            do {
                let result = try await interactor.selectContent(oldModel: selectedItem, newModel: item)
                processOnItemClicked(isAdded: result)
            } catch {
                processOnItemClickedError(error: error)
            }
        }
    }
    
    private func processOnItemClicked(isAdded: Bool) {
        if isAdded {
            navigationState = NavigationState.back(isMain: !isBackEnabled)
            return
        } else {
            errorMessage = ErrorMessageState.notAddedContentIsExists
            return
        }
    }
    
    private func processOnItemClickedError(error: Error) {
        logger.recordError(error: error)
        
        if error is ContentNotValidError {
            errorMessage = ErrorMessageState.notSelectAndDelete
        } else if let verificationError = error as? ContentVerificationError {
            errorMessage = ErrorMessageState.verifyError(verificationError)
        } else {
            errorMessage = ErrorMessageState.selectIsFailed
        }
    }
    
    private func onDeleteClicked(item: ContentModel) {
        logger.print(
            tag: loggerTag,
            message: "On delete clicked"
        )
        
        Task {
            do {
                let items = items
                let selectedItem = items.first(
                    where: {
                        $0.isChecked
                    }
                )
                
                if items.count == 1 {
                    errorMessage = .oneItemNotDelete
                } else if item == selectedItem {
                    errorMessage = .selectedItemNotDelete
                } else {
                    try await interactor.deleteContent(id: item.id)
                }
            } catch {
                processError(error: error)
                errorMessage = .deleteIsFailed
            }
        }
    }
    
    private func processError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func onOpenFileClicked() {
        logger.print(
            tag: loggerTag,
            message: "Open file provider clicked"
        )
        
        startFileProvider = true
    }
    
    private func onOpenFileHandled() {
        logger.print(
            tag: loggerTag,
            message: "Open file provider handled"
        )
        
        startFileProvider = false
    }
    
    private func onDocumentResult(uri: URL?) {
        guard let uri = uri else {
            logger.print(
                tag: loggerTag,
                message: "Document result is failed. Content uri is nil"
            )
            
            errorMessage = ErrorMessageState.uriIsNull
            
            return
        }
        
        logger.print(
            tag: loggerTag,
            message: "Document result is successful. Content uri: \(uri.absoluteString)"
        )
        
        Task {
            do {
                let selectedItem = items.first { $0.isChecked }
                let fileUriAbsoluteString = uri.absoluteString
                let contentName = try await interactor.getContentNameFromUri(uri: fileUriAbsoluteString)
                
                let isAdded = try await interactor.addContent(
                    oldModel: selectedItem,
                    contentName: contentName,
                    uri: fileUriAbsoluteString
                )
                
                processOnItemClicked(isAdded: isAdded)
            } catch {
                processOnDocumentResultError(error: error)
            }
        }
    }
    
    private func processOnDocumentResultError(error: Error) {
        processError(error: error)
        
        if let verificationError = error as? ContentVerificationError {
            errorMessage = .verifyError(verificationError)
        } else {
            errorMessage = .addIsFailed
        }
    }
    
    private func onDocumentResultError(error: Error) {
        logger.print(
            tag: loggerTag,
            message: "Document result is failed: \(error.localizedDescription)"
        )
        
        processError(error: error)
        
        errorMessage = ErrorMessageState.uriIsNull
    }
    
    private func onContentFormatClicked() {
        logger.print(
            tag: loggerTag,
            message: "Content format clicked"
        )
        
        Task {
            do {
                let url = try await interactor.getContentFormatUrl()
                navigationState = NavigationState.navigateToContentFormat(url: url)
            } catch {
                processError(error: error)
                
                errorMessage = ErrorMessageState.contentFormatUrlNotLoaded
            }
        }
    }
    
    private func onNavigationHandled() {
        logger.print(
            tag: loggerTag,
            message: "On navigation handled"
        )
        
        navigationState = nil
    }
}
