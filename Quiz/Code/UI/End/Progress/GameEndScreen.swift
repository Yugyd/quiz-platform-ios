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

struct GameEndScreen: View {
    
    var onNavigateToErrorsList: () -> Void
    var onNaviateToGame: (Mode, Bool) -> Void
    
    @ObservedObject var viewModel: GameEndViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingScreen()
            } else {
                VStack(alignment: .center) {
                    Group {
                        switch viewModel.themeTitle {
                        case .error:
                            Text(
                                "end_title_work_error",
                                tableName: appLocalizable
                            )
                        case .themeTitle(let title):
                            Text(title)
                        case .none:
                            Text("")
                        }
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.mdOnBackground)
                    .font(.title)
                    
                    Spacer().frame(height: 16)
                    
                    let progressTint = ProgressColor.getColor(
                        level: viewModel.progressLevel
                    )
                    ProgressView(
                        value: Float(viewModel.progressPercent),
                        total: 100.0
                    )
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: progressTint)
                    )
                    .frame(height: 8)
                    .frame(minWidth: 100, maxWidth: 240)
                    
                    Spacer().frame(height: 16)
                    
                    Group {
                        let point = viewModel.progressPoint
                        let count = viewModel.progressCount
                        
                        Text("\(point)\(Text("design_system_format_record_progress", tableName: appLocalizable))\(count)")
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.mdOnSurfaceVariant)
                    .font(.body)
                    
                    Spacer().frame(height: 16)
                    
                    PrimaryButton(
                        title: Text(
                            "end_action_new_game",
                            tableName: appLocalizable
                        ),
                        action: {
                            viewModel.onAction(action: .onNewGameClicked)
                        }
                    )
                    
                    if viewModel.isErrorsButtonVisible {
                        Spacer().frame(height: 8)
                        
                        TonalButton(
                            title: Text(
                                "end_action_show_error",
                                tableName: appLocalizable
                            ),
                            action: {
                                viewModel.onAction(action: .onShowErrorsClicked)
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToErrorsList:
                onNavigateToErrorsList()
            case .navigateToGame(let mode, let isRewardedSuccess):
                onNaviateToGame(mode, isRewardedSuccess)
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
    GameEndScreen(
        onNavigateToErrorsList: {},
        onNaviateToGame: { _, _ in },
        viewModel: GameEndViewModel(
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            data: ProgressEnd(
                mode: Mode.arcade,
                themeId: 3,
                point: 12,
                count: 20,
                errorQuestIds: Set()
            ),
            isRewardedOpen: false,
            logger: IocContainer.app.resolve(),
            featureManager: IocContainer.app.resolve()
        )
    )
}
