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

struct RecordEndScreen: View {
    
    var onNavigateToGameEnd: () -> Void
    var onNavigateToRate: () -> Void
    var onNavigateToTelegram: () -> Void
    var onBack: () -> Void
    
    @ObservedObject var viewModel: RecordEndViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                IconWithBackground(
                    size: 96,
                    icon: "ic_rewarded_ads"
                )
                
                Spacer().frame(height: 32)
                
                Group {
                    if let title = viewModel.title {
                        Text(title)
                    } else {
                        Text(
                            "end_title_well",
                            tableName: appLocalizable
                        )
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdOnBackground)
                .font(.title)
                
                Spacer().frame(height: 16)
                
                Group {
                    if let subtitle = viewModel.subtitle {
                        Text(subtitle)
                    } else {
                        Text(
                            "end_msg_new_record",
                            tableName: appLocalizable
                        )
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdOnSurfaceVariant)
                .font(.body)
                
                Spacer().frame(height: 16)
                
                PrimaryButton(
                    title: {
                        switch viewModel.buttonType {
                        case .rate:
                            Text(
                                "end_action_leave_rate",
                                tableName: appLocalizable
                            )
                        case .telegram(let buttonText):
                            Text(buttonText)
                        }
                    }(),
                    action: {
                        viewModel.onAction(action: .onActionClicked)
                    }
                )
                
                Spacer().frame(height: 8)
                
                TonalButton(
                    title: Text(
                            "end_action_skip",
                            tableName: appLocalizable
                        )
                    ,
                    action: {
                        viewModel.onAction(action: .onSkipClicked)
                    }
                )
            }
            .padding()
        }
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToRate:
                onNavigateToRate()
            case .navigateToTelegram:
                onNavigateToTelegram()
            case .navigateToGameEnd:
                onNavigateToGameEnd()
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
    RecordEndScreen(
        onNavigateToGameEnd: {},
        onNavigateToRate: {},
        onNavigateToTelegram: {},
        onBack: {},
        viewModel: RecordEndViewModel(
            featureManager: IocContainer.app.resolve(),
            remoteConfigRepository: IocContainer.app.resolve(),
            mode: Mode.arcade,
            logger: IocContainer.app.resolve()
        )
    )
}
