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

import Combine
import Foundation

@MainActor class CorrectPresenter: CorrectPresenterProtocol {
    
    var isHaveErrors: Bool = false
    
    fileprivate weak var rootView: CorrectViewProtocol?
    
    nonisolated private let repository: ErrorRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        repository: ErrorRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.repository = repository
        self.contentInteractor = contentInteractor
        self.logger = logger
    }

    func attachView(rootView: CorrectViewProtocol) {
        self.rootView = rootView
    }
    
    func loadData() {
        subscribeToSelectedContent()
    }
    
    // MARK: - Private selected content
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error: error)
                    }
                },
                receiveValue: {  [weak self] content in
                    self?.processContent(content: content)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContent(content: ContentModel?) {
        Task {
            let isHaveErrors = await loadErrorData()
            handleData(data: isHaveErrors)
        }
    }
    
    // MARK: - Private load error data
    
    private func loadErrorData() async -> Bool {
        let isHaveErrors = await withUnsafeContinuation { continuation in
            DispatchQueue.global().async { [weak self] in
                let isHaveErrors = self?.repository.isHaveErrors()
                continuation.resume(returning: isHaveErrors)
            }
        }
        return isHaveErrors ?? false
    }
    
    private func handleData(data: Bool?) {
        guard let data = data else {
            rootView?.setEmptyStub()
            return
        }
        
        isHaveErrors = data
        
        let contentMode: ContentMode = IocContainer.app.resolve()
        if contentMode == .pro {
            rootView?.enableStartButton(isEnable: isHaveErrors)
            rootView?.hideInfoLabel(isHide: true)
        } else {
            rootView?.enableStartButton(isEnable: false)
            rootView?.hideInfoLabel(isHide: false)
        }
    }
}
