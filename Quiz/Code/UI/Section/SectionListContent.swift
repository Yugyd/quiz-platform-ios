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

struct SectionListContent: View {
    
    let sections: [SectionUiModel]
    let onSectionClicked: (SectionUiModel) -> Void
    
    private let itemSpacing: CGFloat = 8
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: itemSpacing
            ) {
                ForEach(
                    sections,
                    id: \.id
                ) { item in
                    SectionItemView(model: item) {
                        onSectionClicked(item)
                    }
                    .aspectRatio(
                        1,
                        contentMode: .fit
                    )
                }
            }
            .padding(itemSpacing)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
    }
}

#Preview {
    let section = Section(
        id: 1,
        count: 10,
        questIds: [1, 2],
        point: 5
    )
    let sectionWithLevel = SectionWithLevel(
        item: section,
        level: SectionLevel.normal
    )
    SectionListContent(
        sections: [
            SectionUiModel(
                id: 2,
                item: sectionWithLevel,
                positionState: SectionPositionState.below
            ),
            SectionUiModel(
                id: 3,
                item: sectionWithLevel,
                positionState: SectionPositionState.latest
            ),
            SectionUiModel(
                id: 4,
                item: sectionWithLevel,
                positionState: SectionPositionState.above
            )
        ],
        onSectionClicked: {_ in}
    )
}
