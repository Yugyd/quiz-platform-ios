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

struct ThemeListContent: View {
    
    let items: [ThemeUiModel]
    
    let onStartClicked: (ThemeUiModel) -> Void
    let onInfoClicked: (ThemeUiModel) -> Void
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                ThemeItem(
                    model: item,
                    onStartClicked: { onStartClicked(item)
                    },
                    onInfoClicked: {
                        onInfoClicked(item)
                    }
                )
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let point = Point(
        count: 20,
        arcade: 16,
        marathon: 16,
        sprint: 16
    )
    let theme = Theme(
        id: 1,
        name: "Title",
        info: "Info",
        image: nil,
        count: 16,
        ordinal: 1,
        point: point
    )
    ThemeListContent(
        items: [
            ThemeUiModel(
                id: 1,
                theme: theme,
                progressPercent: 70,
                progressLevel: ProgressLevel.high
            )
        ],
        onStartClicked: {_ in},
        onInfoClicked: {_ in}
    )
}
