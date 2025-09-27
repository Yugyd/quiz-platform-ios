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

struct GameScreen: View {
    
    var onNavigateToProgressEnd: (EndSequeExtraArgs) -> Void
    var onNavigateToGameEnd: (EndSequeExtraArgs) -> Void
        
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning || viewModel.quest == nil {
                WarningScreen(
                    isRetryButtonEnabled: .constant(false),
                    onRetryClicked: nil
                )
            } else {
                VStack() {
                    let progressLevel = ProgressLevel.defineLevel(
                        progressPercent: viewModel.control.progress
                    )
                    let progressTint = ProgressColor.getColor(
                        level: progressLevel
                    )
                    
                    ProgressView(
                        value: Float(viewModel.control.progress),
                        total: 100.0
                    )
                    .progressViewStyle(
                        LinearProgressViewStyle(tint: progressTint)
                    )
                    .frame(height: 8)
                    .frame(maxWidth: .infinity)
                    .padding(0)
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                switch viewModel.quest!.type {
                                case QuestUiType.enter:
                                    EnterQuestContent(
                                        quest: viewModel.quest!.quest,
                                        isNumberKeyboard: viewModel.quest!.isNumberKeyboard,
                                        manualAnswer: viewModel.manualAnswer,
                                        trueAnswer: viewModel.quest?.trueAnswer,
                                        answers: viewModel.answers,
                                        onAnswerHandler: {
                                            viewModel.onAction(
                                                action: .onAnswerSelected(
                                                    userAnswer: viewModel.manualAnswer,
                                                    isSelected: true
                                                )
                                            )
                                        },
                                        onAnswerTextChanged: { newAnswer in
                                            viewModel.onAction(
                                                action: .onAnswerTextChanged(
                                                    userAnswer: newAnswer
                                                )
                                            )
                                        }
                                    )
                                case QuestUiType.simple:
                                    SimpleQuestContent(
                                        quest: viewModel.quest!.quest,
                                        answers: viewModel.quest!.answers,
                                        answersModel: viewModel.answers,
                                        onAnswerClicked: { answer in
                                            viewModel.onAction(
                                                action: .onAnswerSelected(
                                                    userAnswer: answer,
                                                    isSelected: true
                                                )
                                            )
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .onChange(of: viewModel.scrollToTopAnimation) { shouldScroll in
                            if shouldScroll {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                                
                                viewModel.onAction(action: .onScrollToTopAnimationEnded)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToProgressEnd(let args):
                onNavigateToProgressEnd(args)
            case .navigateToGameEnd(let args):
                onNavigateToGameEnd(args)
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
    GameScreen(
        onNavigateToProgressEnd: { _ in },
        onNavigateToGameEnd: { _ in },
        viewModel: GameViewModel(
            logger: IocContainer.app.resolve(),
            time: IocContainer.app.resolve(),
            abParser: IocContainer.app.resolve(),
            preferences: IocContainer.app.resolve(),
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            initialArgs: GameInitialArgs(
                mode: .arcade,
                themeId: 1,
                sectionId: 2,
                recordValue: 3
            ),
            aiTasksInteractor: IocContainer.app.resolve()
        )
    )
}
