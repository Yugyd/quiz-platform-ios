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

struct SubCourseListScreen: View {
   
    @ObservedObject var viewModel: SubCourseListViewModel
    
    // Navigation callbacks
    let onBack: () -> Void
    let onNavigateToSubCourse: (SubCoursesInitialArgs) -> Void
    let onNavigateToCourseDetails: (Int, String) -> Void
    
    var body: some View {
        ZStack() {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning {
                WarningScreen(
                    isRetryButtonEnabled: .constant(false),
                    onRetryClicked: nil
                )
            } else {
                SubCourseListContent(
                    useParentType: false,
                    items: viewModel.items,
                    courseBanner: viewModel.continueCourseBanner,
                    onItemClicked: { item in
                        viewModel.onAction(.onCourseClicked(item: item))
                    },
                    onBannerConfirmClicked: {
                        viewModel.onAction(.onContinueThemeBannerClicked)
                    },
                    onBannerHideClicked: {
                        viewModel.onAction(.onHideThemeBannerClicked)
                    }
                )
            }
        }
        .toastViewOverlay(
            isPresented: $viewModel.showErrorMessage,
            message: Text("design_system_error_base", tableName: appLocalizable),
            onDismiss: {
                viewModel.onAction(.onSnackbarDismissed)
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToSubCourse(let id, let title, let isHideContinueBanner):
                onNavigateToSubCourse(.init(courseId: id, courseTitle: title, isHideContinueBanner: isHideContinueBanner))
            case .navigateToCourseDetail(let id, let title):
                onNavigateToCourseDetails(id, title)
            case .back:
                onBack()
            case .none:
                break
            }
            if navigationState != nil {
                viewModel.onAction(.onNavigationHandled)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = SubCourseListViewModel(
        initialArgs: .init(
            courseId: 1,
            courseTitle: "Parent Course",
            isHideContinueBanner: false
        ),
        courseInteractor: IocContainer.app.resolve(),
        logger: IocContainer.app.resolve()
    )
    vm.items = [
        CourseModel(
            id: 1, name: "Math", description: "desc", icon: nil, parentCourseId: nil, isDetail: false
        ),
        CourseModel(
            id: 2, name: "Physics", description: "desc", icon: nil, parentCourseId: nil, isDetail: false
        )
    ]
    vm.continueCourseBanner = ContinueCourseBannerUiModel(id: 1, title: "Continue Course")
   
    return SubCourseListScreen(
        viewModel: vm,
        onBack: {},
        onNavigateToSubCourse: {_ in},
        onNavigateToCourseDetails: {_, _ in}
    )
}
