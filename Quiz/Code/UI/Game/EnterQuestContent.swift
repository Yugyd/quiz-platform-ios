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

struct EnterQuestContent: View {
    
    let quest: String
    let isNumberKeyboard: Bool
    let manualAnswer: String
    let trueAnswer: String?
    let answers: AnswersModel
    
    private var answerState: AnswerState {
        let answerState: AnswerState
        if answers.isCorrect {
            answerState = AnswerState.success
        } else if !answers.isCorrect && answers.selectedAnswerIndex != nil {
            answerState = AnswerState.failed
        } else {
            answerState = AnswerState.none
        }
        return answerState
    }
    
    private var formColor: Color? {
        switch answerState {
        case .success:
            return .green
        case .failed:
            return .red
        case .none:
            return nil // default system color
        }
    }
    
    var onAnswerHandler: () -> Void
    var onAnswerTextChanged: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            QuestComponent(quest: quest)
            
            let isError = answerState == .failed
            
            HStack {
                TextField(
                    String(localized: "enter_quest_correct_answer", table: appLocalizable),
                    text: Binding(
                        get: { manualAnswer },
                        set: { onAnswerTextChanged($0) }
                    ),
                    onCommit: {
                        onAnswerHandler()
                    }
                )
                .keyboardType(isNumberKeyboard ? .numberPad : .default)
                .disabled(!answers.answerButtonIsEnabled)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(formColor)
                .onChange(of: manualAnswer) { newValue in
                    onAnswerTextChanged(newValue)
                }
            }
            .padding(.horizontal, 16)
            
            if isError && trueAnswer != nil {
                Text(trueAnswer!).foregroundColor(.red).padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Preview

struct EnterQuestContent_Previews: PreviewProvider {
    static var previews: some View {
        EnterQuestContent(
            quest: "What is 2 + 2?",
            isNumberKeyboard: true,
            manualAnswer: "3",
            trueAnswer: "4",
            answers: AnswersModel(
                trueAnswerIndex: 0,
                selectedAnswerIndex: 0,
                isCorrect: false,
                answerButtonIsEnabled: false
            ),
            onAnswerHandler: {},
            onAnswerTextChanged: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
