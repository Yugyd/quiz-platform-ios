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

struct ContentItem: View {
    static let NAME_FIRST_SYMBOL = 1
    
    let model: ContentModel
    let onItemClicked: (ContentModel) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            leadingContent
            
            Spacer().frame(width: 16)
            
            headlineContent
            
            Spacer()
            
            trailingContent
        }
        .onTapGesture {
            onItemClicked(model)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.mdSurface)
    }
    
    @ViewBuilder
    var leadingContent: some View {
        ZStack {
            Circle()
                .fill(Color.mdPrimaryContainer)
                .frame(
                    width: IconConstans.mdIconContainerSize,
                    height: IconConstans.mdIconContainerSize
                )
            
            Text(
                String(
                    model.name
                        .prefix(ContentItem.NAME_FIRST_SYMBOL)
                        .uppercased()
                )
            )
            .foregroundColor(
                Color.mdOnPrimaryContainer
            )
            .font(.title2)
        }
    }
    
    @ViewBuilder
    var headlineContent: some View {
        Text(model.name)
            .foregroundStyle(Color.mdOnSurface)
            .font(.body)
    }
    
    @ViewBuilder
    var trailingContent: some View {
        ZStack {
            if model.isChecked {
                Image("ic_check")
                    .frame(
                        width: IconConstans.mdDefaultIconSize,
                        height: IconConstans.mdDefaultIconSize
                    )
            } else {
                EmptyView()
            }
        }
        .frame(
            width: IconConstans.mdIconContainerSize,
            height: IconConstans.mdIconContainerSize
        )
    }
}

struct ContentItem_Previews: PreviewProvider {
    static var previews: some View {
        ContentItem(
            model: ContentModel(
                id: "1",
                name: "Item 1",
                filePath: "",
                isChecked: true,
                contentMarker: ""
            ),
            onItemClicked: { _ in }
        )
        .previewLayout(.sizeThatFits)
        
        ContentItem(
            model: ContentModel(
                id: "2",
                name: "Item 2",
                filePath: "",
                isChecked: false,
                contentMarker: ""
            ),
            onItemClicked: { _ in }
        )
        .previewLayout(.sizeThatFits)
    }
}
