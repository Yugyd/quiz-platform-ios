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

struct ThemeScreen: View {
    
    var onNavigateToGame: (ThemeSenderArgs) -> Void
    var onNavigateToSection: (ThemeSenderArgs) -> Void
    
    @ObservedObject var viewModel: ThemeViewModel
    
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
                ThemeListContent(
                    items: viewModel.items,
                    onStartClicked: { theme in
                        viewModel.onAction(action: .onStartClicked(theme.theme))
                    },
                    onInfoClicked: {theme in
                        viewModel.onAction(action: .onInfoClicked(theme.theme))
                    }
                )
            }
        }
        .sheet(
            item: $viewModel.showInfoDialog,
            onDismiss: { viewModel.onAction(action: .onInfoDialogDismissed) }
        ) { theme in
            InfoSheetView(
                theme: theme,
                onStartClicked: { theme in
                    viewModel.onAction(action: .onInfoDialogDismissed)
                    viewModel.onAction(action: .onStartClicked(theme))
                },
                onDismiss: { viewModel.onAction(action: .onInfoDialogDismissed) }
            )
            .modifier(PresentationModifier())
        }
        .toastViewOverlay(
            isPresented: $viewModel.showErrorMessage,
            message: Text(
                "design_system_error_base",
                tableName: appLocalizable
            ),
            onDismiss: {
                viewModel.onAction(action: .onErrorMessageDismissed)
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToGame(let theme):
                onNavigateToGame(theme)
            case .navigateToSection(let theme):
                onNavigateToSection(theme)
            case .none:
                break
            }
            
            if navigationState != nil {
                viewModel.onAction(action: .onNavigationHandled)
            }
        }
    }
}

struct PresentationModifier: ViewModifier {
    
    func body(content: Self.Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.fraction(0.3), .medium])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

#Preview {
    ThemeScreen(
        onNavigateToGame: {_ in },
        onNavigateToSection: {_ in },
        viewModel: ThemeViewModel(
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
    )
}
