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

struct ErrorItem: View {
    
    let model: ErrorQuest
    let onItemClicked: (ErrorQuest) -> Void
    let onFavoriteClicked: (ErrorQuest) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(
                    "errors_title_quest",
                    tableName: appLocalizable
                )
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                
                Text(model.quest)
                    .font(.footnote)
                    .foregroundColor(.mdOnSurfaceVariant)
                
                Spacer().frame(height: 8)
                
                Text(
                    "errors_title_true_answer",
                    tableName: appLocalizable
                )
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                
                Text(model.trueAnswer)
                    .font(.footnote)
                    .foregroundColor(.mdOnSurfaceVariant)
            }
            
            Spacer()
            
            if false {
                // TODO Add favorite icon impl
            }
        }
        .padding(16)
        .background(Color.mdSurface)
        .contentShape(Rectangle())
        .onTapGesture {
            onItemClicked(model)
        }
    }
}

#Preview {
    ErrorItem(
        model: ErrorQuest(
            id: 1,
            quest: "Quest",
            trueAnswer: "True answer"
        ),
        onItemClicked: {_ in},
        onFavoriteClicked: {_ in }
    )
}
