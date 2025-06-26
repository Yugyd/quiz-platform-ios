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

struct ProgressListView: View {
    
    let header: ProgressHeaderUiModel?
    let items: [ProgressUiModel]
    let onItemClicked: (ProgressUiModel) -> Void

    var body: some View {
        List {
            if let header = header {
                ProgressHeaderItemView(
                    model: header
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            
            ForEach(items, id: \.id) { item in
                ProgressItemView(model: item) {
                    onItemClicked(item)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.visible)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let headerModel = ProgressHeaderUiModel(
        progressPercent: 85,
        levelDegree: .academic,
        progressLevel: .high
    )
    
    let items = [
        ProgressUiModel(
            id: 1,
            title: "Math",
            subtitle: "Test",
            value: "30%",
            progressColor: .mdPrimary
        ),
        ProgressUiModel(
            id: 2,
            title: "History",
            subtitle: "Test",
            value: "30%",
            progressColor: .mdPrimary
        )
    ]
    
    ProgressListView(
        header: headerModel,
        items: items,
        onItemClicked: { _ in }
    )
}
