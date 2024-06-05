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

@MainActor class SectionPresenter: SectionPresenterProtocol {
    
    typealias ThemeSectionRepositoryProtocol = ThemeRepositoryProtocol & SectionRepositoryProtocol
    
    var theme: Theme?
    var sections: [Section] = []
    var sectionWithLevels: [SectionWithLevel] = []
    var contentModel: ContentModel?
    
    private weak var rootView: SectionViewProtocol?
    
    private var themeId: Int
    
    nonisolated private let contentRepository: ThemeSectionRepositoryProtocol
    nonisolated private let userRepository: SectionPointRepositoryProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var latestSectionId: Int?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        contentRepository: ThemeSectionRepositoryProtocol,
        userRepository: SectionPointRepositoryProtocol,
        themeId: Int,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository
        self.themeId = themeId
        self.contentInteractor = contentInteractor
        self.logger = logger
        
    }
    
    func attachView(rootView: SectionViewProtocol) {
        self.rootView = rootView
    }
    
    func loadData() {
        loadSetionsData()
        subscribeToSelectedContent()
    }
    
    // MARK: - Private load progress data
    
    private func loadSetionsData() {
        Task {
            let contentAndResult = await self.loadSetionsData(themeId: self.themeId)
            handleData(
                themeData: contentAndResult.themeData,
                sectionsData: contentAndResult.sectionsData
            )
        }
    }
    
    private func loadSetionsData(themeId: Int) async -> ContentAndResult {
        return await withUnsafeContinuation { continuation in
            DispatchQueue.global().async { [weak self] in
                let themeData = self?.contentRepository.getTheme(id: themeId)
                let sectionsData = self?.contentRepository.getSections(theme: themeId)
                
                var sectionsResult: [Section]?
                if let data = sectionsData {
                    sectionsResult = self?.userRepository.attachPoints(sections: data)
                }
                
                let contentAndResult = ContentAndResult(
                    themeData: themeData!,
                    sectionsData: sectionsResult
                )
                continuation.resume(returning: contentAndResult)
            }
        }
    }
    
    
    func isLatestSection(id: Int) -> Int {
        guard let latestSectionId = latestSectionId else {
            return -1
        }
        
        if id < latestSectionId {
            return -1
        } else if id > latestSectionId {
            return 1
        } else {
            return 0
        }
    }
    
    // MARK: - Private selected content
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .map { newModel in
                self.contentInteractor.isResetNavigation(
                    oldModel: self.contentModel,
                    newModel: newModel
                )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error: error)
                    }
                },
                receiveValue: { [weak self] contentResult in
                    self?.processContentResetEvent(model: contentResult)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContentResetEvent(model: ContentResult) {
        if (model.isBack) {
            rootView?.onBack()
        }
        
        self.contentModel = model.newModel
    }
    
    //    MARK: - Private
    
    private func handleData(themeData: Theme?, sectionsData: [Section]?) {
        self.theme = themeData
        self.sections = sectionsData ?? []
        self.sectionWithLevels = sections.map {
            let percent = Percent.calculatePercent(value: ($0.point ?? 0), count: $0.count)
            return SectionWithLevel(item: $0, level: SectionLevel.defineLevel(progressPercent: percent))
        }
        self.latestSectionId = sectionWithLevels.first {
            return $0.level == .empty || $0.level == .low
        }
        .map {
            return $0.item.id
        }
        
        if sections.isEmpty {
            rootView?.setEmptyStub()
        } else {
            rootView?.updateCollection()
        }
    }
    
    struct ContentAndResult {
        let themeData: Theme
        let sectionsData: [Section]?
    }
}
