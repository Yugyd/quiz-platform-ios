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
class CoursesViewModel: ObservableObject {
    
    private let loggerTag = "CoursesViewModel"
    
    // State
    @Published var isWarning: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorMessage: Bool = false
    
    @Published var parentCourseTitle: String = ""
    @Published var items: [CourseModel] = []
    @Published var continueCourseBanner: ContinueCourseBannerUiModel?
    
    @Published var navigationState: CoursesNavigationState?
    
    private let courseInteractor: CourseInteractor
    private let logger: Logger
    
    init(
        courseInteractor: CourseInteractor,
        logger: Logger
    ) {
        self.courseInteractor = courseInteractor
        self.logger = logger
    }
    
    func onAction(_ action: CoursesAction) {
        switch action {
        case .loadData:
            loadData()
        case .onContinueThemeBannerClicked:
            onContinueThemeBannerClicked()
        case .onHideThemeBannerClicked:
            onHideThemeBannerClicked()
        case let .onCourseClicked(item):
            onCourseClicked(item: item)
        case .onSnackbarDismissed:
            onSnackbarDismissed()
        case .onNavigationHandled:
            onNavigationHandled()
        }
    }
    
    // MARK: - Actions
    
    private func onContinueThemeBannerClicked() {
        guard let continueBanner = continueCourseBanner else { return }
        navigationState = .navigateToCourseDetail(id: continueBanner.id, title: continueBanner.title)
    }
    
    private func onHideThemeBannerClicked() {
        continueCourseBanner = nil
    }
    
    private func onCourseClicked(item: CourseModel) {
        if item.isDetail {
            navigationState = .navigateToCourseDetail(id: item.id, title: item.name)
        } else {
            navigationState = .navigateToSubCourse(
                id: item.id,
                title: item.name,
                isHideContinueBanner: continueCourseBanner == nil
            )
        }
    }
    
    private func onSnackbarDismissed() {
        showErrorMessage = false
    }
    
    private func onNavigationHandled() {
        navigationState = nil
    }
    
    // MARK: - Load data
    
    private func loadData() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            showLoading()
            
            do {
                let courses = try await courseInteractor.getCourses()
                let currentCourse = try await courseInteractor.getCurrentCourse()
                let banner = currentCourse.map {
                    ContinueCourseBannerUiModel(
                        id: $0.id,
                        title: $0.name
                    )
                }
                
                showDataState(items: courses, continueCourseBanner: banner)
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
    
    // MARK: - State management
    
    private func showLoading() {
        isLoading = true
        isWarning = false
        
        items = []
        continueCourseBanner = nil
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
        
        items = []
        continueCourseBanner = nil
    }
    
    private func showDataState(
        items: [CourseModel],
        continueCourseBanner: ContinueCourseBannerUiModel?
    ) {
        isLoading = false
        isWarning = false
        
        self.items = items
        self.continueCourseBanner = continueCourseBanner
    }
}
