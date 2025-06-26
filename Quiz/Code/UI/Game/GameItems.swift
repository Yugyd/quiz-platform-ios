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

struct QuestComponent: View {
    
    let quest: String
    
    var body: some View {
        VStack {
            Text(quest)
                .font(.title3)
                .foregroundColor(.mdOnBackground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 16)
        }
    }
}

struct AnswerItemButton: View {
    
    let answer: String
    let textColor: Color?
    let isEnabled: Bool
    let onAnswerClicked: () -> Void
    
    var body: some View {
        Button(
            action: {
                if isEnabled {
                    onAnswerClicked()
                }
            }
        ) {
            Text(answer)
                .font(.body) // similar to MaterialTheme.typography.bodyLarge
                .foregroundColor(textColor ?? .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8) // approximate ButtonDefaults padding
                .padding(.horizontal, 16) // horizontalMargin = 16.dp
                .contentShape(Rectangle()) // make whole padded area tappable
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
        .background(Color.clear)
        .cornerRadius(0)
    }
}

struct QuestComponent_Previews: PreviewProvider {
    static var previews: some View {
        QuestComponent(
            quest: "What is the capital of France?"
        )
        .previewLayout(.sizeThatFits)
    }
}

struct AnswerButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            AnswerItemButton(
                answer: "Option 0",
                textColor: .blue,
                isEnabled: true,
                onAnswerClicked: {}
            )
            
            AnswerItemButton(
                answer: "Option 1",
                textColor: .green,
                isEnabled: true,
                onAnswerClicked: {}
            )
            
            AnswerItemButton(
                answer: "Option 2",
                textColor: .red,
                isEnabled: true,
                onAnswerClicked: {}
            )
            
            AnswerItemButton(
                answer: "Option 2",
                textColor: .green,
                isEnabled: false,
                onAnswerClicked: {}
            )
            
            AnswerItemButton(
                answer: "Option 3",
                textColor: .red,
                isEnabled: false,
                onAnswerClicked: {}
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
