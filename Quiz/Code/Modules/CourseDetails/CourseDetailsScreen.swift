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

import SwiftUI
import MarkdownUI

struct CourseDetailsScreen: View {
    
    // Navigation handlers
    let onBack: () -> Void
    let onNavigateToAiTasks: (Int) -> Void
    let onNavigateToExternalReportError: (Int, String) -> Void
    
    // ViewModel
    @ObservedObject var viewModel: CourseDetailsViewModel
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning {
                WarningScreen(
                    isRetryButtonEnabled: .constant(false),
                    onRetryClicked: nil
                )
            } else {
                CourseDetailsContent(
                    course: viewModel.courseDetailsDomainState,
                    isActionsVisible: viewModel.isActionsVisible,
                    onTasksClicked: {
                        viewModel.onAction(action: .onTasksClicked)
                    }
                )
                .padding(0)
            }
        }
        .toastViewOverlay(
            isPresented: Binding(
                get: { viewModel.showErrorMessage != nil },
                set: { _ in }
            ),
            message: {
                if let errorMessage = viewModel.showErrorMessage {
                    // Handle different error cases
                    switch errorMessage {
                    case .error:
                        return Text("design_system_error_base", tableName: appLocalizable)
                    case .aiTasksEmpty:
                        return Text("design_system_error_base", tableName: appLocalizable)
                    case .aiTasksError:
                        return Text("design_system_error_base", tableName: appLocalizable)
                    case .aiUnauthorized:
                        return Text("design_system_error_base", tableName: appLocalizable)
                    }
                } else {
                    return Text("")
                }
            }(),
            onDismiss: {
                viewModel.onAction(action: .onSnackbarDismissed)
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToTasks(let id, let title):
                onNavigateToAiTasks(id)
            case .navigateToExternalPlatformReportError(let id, let body):
                onNavigateToExternalReportError(id, body)
            case .back:
                onBack()
            case .none:
                break
            }
           
            if navigationState != nil {
                viewModel.onAction(action: .onNavigationHandled)
            }
        }
        .background(Color.mdBackground)
    }
}

#Preview {
    CourseDetailsScreen(
        onBack: {},
        onNavigateToAiTasks: {_ in},
        onNavigateToExternalReportError: {_, _ in},
        viewModel: CourseDetailsViewModel(
            initialArgs: CourseDetailsInitialArgs(
                courseId: 1,
                courseTitle: "Title"
            ),
            featureManager: IocContainer.app.resolve(),
            courseInteractor: IocContainer.app.resolve(),
            aiTasksInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
    )
}
