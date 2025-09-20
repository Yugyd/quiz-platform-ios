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

@MainActor
class CourseDetailsViewModel: ObservableObject {

    private let loggerTag = "CourseDetailsViewModel"

    // MARK: - Published State
    @Published var isWarning: Bool = false
    @Published var isLoading: Bool = false
    @Published var showErrorMessage: CourseSnackbarMessage? = nil
    
    @Published var courseDetailsDomainState: CourseDetailsDomainState
    @Published var courseTitle: String = ""
    @Published var isActionsVisible: Bool = false
    @Published var navigationState: CourseDetailsNavigationState? = nil

    // MARK: - Dependencies
    private let initialArgs: CourseDetailsInitialArgs
    private let featureManager: FeatureManager
    private let courseInteractor: CourseInteractor
    private let aiTasksInteractor: AiTasksInteractor
    private let logger: Logger

    // MARK: - Init
    init(
        initialArgs: CourseDetailsInitialArgs,
        featureManager: FeatureManager,
        courseInteractor: CourseInteractor,
        aiTasksInteractor: AiTasksInteractor,
        logger: Logger
    ) {
        self.featureManager = featureManager
        self.courseInteractor = courseInteractor
        self.aiTasksInteractor = aiTasksInteractor
        self.courseDetailsDomainState = CourseDetailsDomainState.empty
        self.logger = logger
        
        self.initialArgs = initialArgs
        self.courseTitle = initialArgs.courseTitle
    }

    // MARK: - Action Handling

    func onAction(action: CourseDetailsAction) {
        switch action {
        case .loadData:
            loadData()
        case .onTasksClicked:
            onTasksClicked()
        case .onReportClicked:
            onReportClicked()
        case .onSnackbarDismissed:
            onSnackbarDismissed()
        case .onNavigationHandled:
            onNavigationHandled()
        case .onBackPressed:
            onBackPressed()
        }
    }

    // MARK: - Action Methods

    private func onTasksClicked() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                self.isLoading = true
                
                guard let courseDetailModel = courseDetailsDomainState.courseDetailModel else { return }

                let aiThemeId = courseDetailModel.id
                try await aiTasksInteractor.fetchAiTasks(aiThemeId: aiThemeId)
                let isHaveAiTasks = try await aiTasksInteractor.isHaveAiTasks(aiThemeId: aiThemeId)
               
                self.processAiTasks(
                    courseDetailModel: courseDetailModel,
                    isContainAiTasks: isHaveAiTasks
                )
            } catch {
                self.logger.logError(error: error)
                self.processAiTasksError(error)
            }
        }
    }

    private func onReportClicked() {
        navigationState = .navigateToExternalPlatformReportError(
            id: initialArgs.courseId,
            content: courseDetailsDomainState.courseDetailModel?.content ?? ""
        )
    }

    private func onSnackbarDismissed() {
        showErrorMessage = nil
    }

    private func onNavigationHandled() {
        navigationState = nil
    }

    private func onBackPressed() {
        navigationState = .back
    }
    
    // MARK: - Private load data
    
    private func loadData() {
        showLoading()
        
        Task { [weak self] in
            guard let self = self else {
                return
            }

            do {
                let isAiTasksEnabled = featureManager.isFeatureEnabled(FeatureToggle.aiTasks)
                let courseDetails = try await courseInteractor.getCourseDetails(courseId: initialArgs.courseId)
                await courseInteractor.setCurrentCourse(courseDetails)
                
                let domainState = CourseDetailsDomainState(
                    courseDetailModel: courseDetails,
                    isAiTasksEnabled: isAiTasksEnabled,
                )
                
                showDataState(
                    domainState: domainState,
                    isActionsVisible: isAiTasksEnabled
                )
            } catch {
                logger.recordError(error: error)
                
                showWarningState()
            }
        }
    }
    
    // MARK: - AI Tasks
    
    private func processAiTasksError(_ error: Error) {
        isLoading = false
      
        showErrorMessage = .aiTasksError
    }
    
    private func processAiTasks(courseDetailModel: CourseDetailModel, isContainAiTasks: Bool) {
        isLoading = false
      
        if isContainAiTasks {
            navigationState = .navigateToTasks(id: courseDetailModel.id, title: courseDetailModel.name)
        } else {
            showErrorMessage = .aiTasksEmpty
        }
    }

    // MARK: - State Management Methods

    private func showLoading() {
        isLoading = true
        isWarning = false
      
        self.courseDetailsDomainState = CourseDetailsDomainState.empty
        self.isActionsVisible  = false
    }

    private func showWarningState() {
        isLoading = false
        isWarning = true
       
        self.courseDetailsDomainState = CourseDetailsDomainState.empty
        self.isActionsVisible  = false
    }

    private func showDataState(domainState: CourseDetailsDomainState, isActionsVisible: Bool) {
        isLoading = false
        isWarning = false
      
        self.courseDetailsDomainState = domainState
        self.isActionsVisible = isActionsVisible
    }
}
