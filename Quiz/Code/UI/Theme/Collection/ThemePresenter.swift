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

@MainActor class ThemePresenter: ThemePresenterProtocol {
    
    nonisolated static let minSectionCountForStartScreen = 1
    
    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol
    
    var themes: [Theme] = [Theme]()
    
    var gameMode: Mode? {
        didSet {
            guard gameMode != nil else {
                return
            }
            progressCalculator = ProgressCalculator.init(mode: gameMode!)
        }
    }
    
    var progressCalculator: ProgressCalculator?
    
    weak fileprivate var rootView: ThemeViewProtocol?
    
    nonisolated private let contentRepository: ThemeSectionRepositoryProtocol
    nonisolated private let userRepository: PointRepositoryProtocol
    private var isSegueAction = false
    
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()
    
    required init(
        contentRepository: ThemeSectionRepositoryProtocol,
        userRepository: PointRepositoryProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.contentInteractor = contentInteractor
        self.logger = logger
    }
    
    func attachRootView(rootView: ThemeViewProtocol) {
        self.rootView = rootView
    }
    
    func loadData() {
        subscribeToSelectedContent()
    }
    
    func calculateProgress(point: Point) -> Int {
        return progressCalculator?.getRecordPercent(point: point) ?? 0
    }
    
    func startSegue(sender: IndexPath) {
        isSegueAction = true
        let themeId = themes[sender.row].id
        
        let gameMode = gameMode
        
        DispatchQueue.global().async { [weak self] in
            let isSection: Bool
            
            if gameMode == .arcade {
                let count = self?.contentRepository.getSectionCount(theme: themeId) ?? 0
                isSection = count >= ThemePresenter.minSectionCountForStartScreen
            } else {
                isSection = false
            }
            
            DispatchQueue.main.async { [weak self] in
                if isSection {
                    self?.startSegueInView(startMode: .section, sender: sender)
                } else {
                    self?.startSegueInView(startMode: .game, sender: sender)
                }
            }
        }
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
            let result = await loadThemeData()
            handleData(data: result)
        }
    }
    
    //    MARK: - Private func
    
    func loadThemeData() async -> [Theme]? {
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
            rootView?.updateCollection()
        }
    }
    
    private func startSegueInView(startMode: StartMode, sender: IndexPath) {
        rootView?.startSegue(startMode: startMode, sender: sender)
        isSegueAction = false
    }
}
