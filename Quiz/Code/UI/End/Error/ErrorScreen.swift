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
import SwiftUI

struct ErrorScreen: View {
    
    var onBack: () -> Void
    var onNavigateToBrowser: (ErrorQuest) -> Void
    
    @ObservedObject var viewModel: ErrorViewModel
    
    private let alertFactory = ContentErrorAlertFactory()
    
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
                ErrorListContent(
                    items: $viewModel.items,
                    onItemClicked: { item in
                        viewModel.onAction(.onItemClicked(item))
                    },
                    onFavoriteClicked: { item in
                        viewModel.onAction(.onFavoriteClicked(item))
                    }
                )
            }
        }
        .toastViewOverlay(
            isPresented: $viewModel.showErrorMessage,
            message: Text("design_system_error_base", tableName: "AppLocalizable"),
            onDismiss: {
                viewModel.onAction(.onErrorMessageDismissed)
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToBrowser(let errorQuest):
                onNavigateToBrowser(errorQuest)
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

#Preview {
    let lineSepartorFormatter: LineSeparatorFormatter = IocContainer.app.resolve()
    
    ErrorScreen(
        onBack: {},
        onNavigateToBrowser: {_ in },
        viewModel: ErrorViewModel(
            repository: IocContainer.app.resolve(),
            aiTasksInteractor: IocContainer.app.resolve(),
            questFormatter: lineSepartorFormatter,
            initialArgs: ErrorsInitialArgs(
                errorIds: Set(),
                mode: nil,
                aiThemeId: nil
            ),
            logger: IocContainer.app.resolve()
        )
    )
}
