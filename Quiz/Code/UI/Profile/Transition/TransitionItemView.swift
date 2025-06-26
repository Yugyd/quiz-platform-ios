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

struct TransitionItem: View {
    let model: TransitionUiModel
    let onItemClicked: (TransitionUiModel) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            headlineContent
            
            Spacer()
            
            trailingContent
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.mdSurface)
        .onTapGesture {
            onItemClicked(model)
        }
    }
    
    @ViewBuilder
    var headlineContent: some View {
        Text(model.value.title)
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

#Preview {
    TransitionItem(
        model: TransitionUiModel(
            id: "1",
            value: TransitionPreference.transition1000,
            isChecked: true
        ),
        onItemClicked: { _ in }
    )
}
