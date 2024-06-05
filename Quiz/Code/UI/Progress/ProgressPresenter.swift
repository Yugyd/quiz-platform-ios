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

@MainActor class ProgressPresenter: ProgressPresenterProtocol {

    var themes: [Theme] = [Theme]()
    var progressCalculator: ProgressCalculator?

    private weak var rootView: ProgressViewProtocol?
    nonisolated private let contentRepository: ThemeRepositoryProtocol
    nonisolated private let userRepository: PointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()

    init(
        contentRepository: ThemeRepositoryProtocol,
        userRepository: PointRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.logger = logger

        self.progressCalculator = ProgressCalculator(delegate: TotalProgressCalculatorDelegate())
    }

    func attachView(rootView: ProgressViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        subscribeToSelectedContent()
    }

    func calculateProgress(point: Point) -> Int {
        return progressCalculator?.getRecordPercent(point: point) ?? 0
    }

    func calculateTotalProgress() -> Int {
        var total = 0
        for theme in themes {
            total += calculateProgress(point: theme.point)
        }
        return total / themes.count
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
            let result = await loadProgressData()
            handleData(data: result)
        }
    }
    

    //    MARK: - Private func
    
    private func loadProgressData() async -> [Theme]? {
        let data = await withUnsafeContinuation { continuation in
            DispatchQueue.global().async { [weak self] in
                let data = self?.contentRepository.getThemes()
                var result: [Theme]?

                if let data = data {
                    result = self?.userRepository.attachPoints(themes: data)
                }
                
                continuation.resume(returning: result)
            }
        }
        return data
    }

    private func handleData(data: [Theme]?) {
        themes = data ?? [Theme]()

        if themes.isEmpty {
            rootView?.setEmptyStub()
        } else {
            rootView?.updateTable()
            loadHeaderData()
        }
    }

    private func loadHeaderData() {
        guard !themes.isEmpty else {
            return
        }

        let progressPercent = calculateTotalProgress()
        let levelDegree = LevelDegree.instanceByProgress(progressPercent: progressPercent)
        let progressLevel = ProgressLevel.defineLevel(progressPercent: progressPercent)
        rootView?.updateTableHeader(progressPercent: progressPercent, levelDegree: levelDegree, progressLevel: progressLevel)
    }
}
