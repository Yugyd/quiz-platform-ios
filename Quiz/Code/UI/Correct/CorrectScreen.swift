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

struct CorrectScreen: View {
    
    var onNavigateToGame: () -> Void
    var onBack: () -> Void
    
    @ObservedObject var viewModel: CorrectViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                IconWithBackground(
                    size: 96,
                    icon: "ic_thumb_up"
                )
                
                Spacer().frame(height: 32)
                
                Text(
                    "correct_title_remember_quest",
                    tableName: appLocalizable
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdOnBackground)
                .font(.title)
                
                Spacer().frame(height: 16)
                
                Text(
                    "correct_msg_correct_quest",
                    tableName: appLocalizable
                )
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdOnSurfaceVariant)
                .font(.body)
                
                Spacer().frame(height: 16)
                
                if viewModel.availableMode == .gameButton {
                    PrimaryButton(
                        title: Text(
                            "design_system_action_game",
                            tableName: appLocalizable
                        ),
                        action: {
                            viewModel.onAction(action: .onStartClicked)
                        }
                    )
                    .disabled(!viewModel.isStartButtonEnabled)
                }
                
                if viewModel.availableMode == .proMessage {
                    Text(
                        "correct_msg_correct_pro_available",
                        tableName: appLocalizable
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.mdPrimary)
                    .font(.body)
                }
            }
            .padding()
        }
        .overlay(
            alignment: Alignment.top,
            content: {
                if (viewModel.showErrorMessage) {
                    ToastView(
                        message: .constant(
                            Text(
                                "design_system_error_base",
                                tableName: appLocalizable
                            )
                        ),
                        onDismissRequest: {
                            viewModel.onAction(action: .onErrorMessageDismissed)
                        }
                    )
                    .padding(.top, 16)
                    .animation(
                        .spring(),
                        value: viewModel.showErrorMessage
                    )
                }
            }
        )
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToGame:
                onNavigateToGame()
            case .back:
                onBack()
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
    CorrectScreen(
        onNavigateToGame: {},
        onBack: {},
        viewModel: CorrectViewModel(
            repository: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
    )
}
