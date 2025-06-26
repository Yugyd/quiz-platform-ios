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

struct SimpleQuestContent: View {
   
    let quest: String
    let answers: [String]
    let answersModel: AnswersModel
    var onAnswerClicked: (String) -> Void

    var body: some View {
        VStack(spacing: 12) {
            QuestComponent(quest: quest)

            ForEach(Array(answers.enumerated()), id: \.offset) { index, answer in
                AnswerItemButton(
                    answer: answer,
                    textColor: getButtonColor(highlight: answersModel, buttonIndex: index),
                    isEnabled: answersModel.answerButtonIsEnabled,
                    onAnswerClicked: {
                        onAnswerClicked(answer)
                    }
                )
            }
        }
        .padding()
    }
}

func getButtonColor(highlight: AnswersModel, buttonIndex: Int) -> Color? {
    if highlight.trueAnswerIndex == nil {
        return nil
    } else if highlight.isCorrect {
        if buttonIndex == highlight.trueAnswerIndex {
            return Color.green
        } else {
            return nil
        }
    } else {
        if buttonIndex == highlight.trueAnswerIndex {
            return Color.green
        } else if buttonIndex == highlight.selectedAnswerIndex {
            return .red
        } else {
            return nil
        }
    }
}

struct SimpleQuestContent_Previews: PreviewProvider {
    static var previews: some View {
        SimpleQuestContent(
            quest: "Quest",
            answers: ["One", "Two", "Three", "Four"],
            answersModel: AnswersModel(
                trueAnswerIndex: 3,
                selectedAnswerIndex: 3,
                isCorrect: true,
                answerButtonIsEnabled: true
            ),
            onAnswerClicked: {_ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
