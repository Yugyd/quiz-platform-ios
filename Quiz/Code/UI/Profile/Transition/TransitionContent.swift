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

struct TransitionContent: View {
    let items: [TransitionUiModel]
    let onItemClicked: (TransitionUiModel) -> Void

    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                TransitionItem(
                    model: item,
                    onItemClicked: onItemClicked
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.inset)
    }
}

#Preview {
    TransitionContent(
        items: [
            TransitionUiModel(
                id: "1",
                value: TransitionPreference.transition1000,
                isChecked: false
            ),
            TransitionUiModel(
                id: "2",
                value: TransitionPreference.transition2000,
                isChecked: true
            ),
        ],
        onItemClicked: { _ in }
    )
    .padding()
    .background(Color.mdBackground)
}
