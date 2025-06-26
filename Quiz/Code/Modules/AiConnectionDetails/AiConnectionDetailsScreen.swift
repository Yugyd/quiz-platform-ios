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

struct AiConnectionDetailsScreen: View {
    
    @ObservedObject var viewModel: AiConnectionDetailsViewModel
    
    var onBack: () -> Void
    var onNavigateToBrowser: (String) -> Void
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning {
                WarningScreen(isRetryButtonEnabled: .constant(false), onRetryClicked: nil)
            } else {
                ScrollView {
                    AiConnectionDetailsContent(
                        name: viewModel.name,
                        provider: viewModel.selectedProvider,
                        allProviders: viewModel.allProviders,
                        isProviderEnabled: viewModel.isProviderEnabled,
                        apiKey: viewModel.apiKey,
                        cloudProjectFolder: viewModel.cloudProjectFolder,
                        isCloudProjectFolderVisible: viewModel.isCloudProjectFolderVisible,
                        isSaveButtonEnabled: viewModel.isSaveButtonEnabled,
                        onKeyInstructionClicked: { viewModel.onAction(.onKeyInstructionClicked) },
                        onSaveClicked: { viewModel.onAction(.onSaveClicked) },
                        onNameChanged: { viewModel.onAction(.onNameChanged($0)) },
                        onProviderSelected: { viewModel.onAction(.onProviderSelected($0)) },
                        onApiKeyChanged: { viewModel.onAction(.onApiKeyChanged($0)) },
                        onCloudProjectFolderChanged: { viewModel.onAction(.onCloudProjectFolderChanged($0)) }
                    )
                    .padding(0)
                }
            }
        }
        // Toast
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
                    case .fillFields:
                        return Text("design_system_error_fields", tableName: appLocalizable)
                    }
                } else {
                    return Text("")
                }
            }(),
            onDismiss: {
                viewModel.onAction(.onSnackbarDismissed)
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .back:
                onBack()
            case .navigateToExternalBrowser(let link):
                onNavigateToBrowser(link)
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
    AiConnectionDetailsScreen(
        viewModel: {
            let vm = AiConnectionDetailsViewModel(
                aiConnectionClient: IocContainer.app.resolve(),
                aiRemoteConfigSource: IocContainer.app.resolve(),
                logger: IocContainer.app.resolve()
            )
            vm.toolbarTitle = .add
            vm.name = "Name"
            vm.selectedProvider = "Provider"
            vm.allProviders = ["Provider", "Another"]
            vm.apiKey = "ApiKey"
            vm.isApiKeyValid = true
            vm.cloudProjectFolder = "CloudFolder"
            vm.isCloudProjectFolderVisible = true
            vm.isSaveButtonEnabled = true
            return vm
        }(),
        onBack: {},
        onNavigateToBrowser: {_ in }
    )
}
