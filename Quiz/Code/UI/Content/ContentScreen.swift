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

struct ContentScreen: View {
    
    var onBack: () -> Void
    var onNavigateToBrowser: (String) -> Void
    
    @StateObject var viewModel: ContentViewModel = ContentViewModel(
        interactor: IocContainer.app.resolve(),
        logger: IocContainer.app.resolve()
    )

    private let contentAlertFactory = ContentErrorAlertFactory()
    
    var body: some View {
        ZStack() {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning {
                WarningScreen(
                    isRetryButtonEnabled: .constant(false),
                    onRetryClicked: nil
                )
            } else if viewModel.items.isEmpty {
                ContentEmptyState(
                    onChooseFileClicked: {
                        viewModel.onAction(action: .onOpenFileClicked)
                    },
                    onDataFormatClicked: {
                        viewModel.onAction(action: .onContentFormatClicked)
                    }
                )
            } else {
                ContentView(
                    items: $viewModel.items,
                    onOpenFileClicked: {
                        viewModel.onAction(action: .onOpenFileClicked)
                    },
                    onContentFormatClicked: {
                        viewModel.onAction(action: .onContentFormatClicked)
                    },
                    onItemClicked: { item in
                        viewModel.onAction(action: .onItemClicked(item))
                    }
                    
                )
            }
        }
        .overlay(
            alignment: Alignment.top,
            content: {
                if (viewModel.errorMessage != nil) {
                    let message = contentAlertFactory.provideErrorMessage(
                        errorMessage: viewModel.errorMessage!
                    )
                    ToastView(
                        message: .constant(message),
                        onDismissRequest: {
                            viewModel.onAction(action: .onErrorMessageDismissed)
                        }
                    )
                    .padding(.top, 16)
                    .animation(
                        .spring(),
                        value: viewModel.errorMessage != nil
                    )
                }
            }
        )
        .fileImporter(
            isPresented: $viewModel.startFileProvider,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false,
            onCompletion: { result in
                viewModel.onAction(action: .onOpenFileProviderHandled)

                switch result {
                case .success(let files):
                    let selectedDocument = files.first
                    viewModel.onAction(action: .onDocumentResult(uri: selectedDocument))
                case .failure(let error):
                    viewModel.onAction(action: .onDocumentResultError(error: error))
                }
            }
        )
        .onReceive(viewModel.$navigationState) { navigationState in
            switch navigationState {
            case .back:
                onBack()
            case let .navigateToContentFormat(url):
                onNavigateToBrowser(url)
            case .none:
                break
            }
            
            if navigationState != nil {
                viewModel.onAction(action: .onNavigationHandled)
            }
        }
    }
}

#Preview {
    ContentScreen(
        onBack: {},
        onNavigateToBrowser: { _ in }
    )
}
