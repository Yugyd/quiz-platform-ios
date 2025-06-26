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

import Foundation
import SwiftUI

struct ThemeItem: View {
    
    let model: ThemeUiModel
    let onStartClicked: () -> Void
    let onInfoClicked: () -> Void
    
    private let aspectRatio: CGFloat = 1.77
    
    var body: some View {
        VStack(spacing: 0) {
            imageContent
            
            VStack(alignment: .leading, spacing: 0) {
                Text(model.theme.name)
                    .font(.headline)
                    .foregroundColor(.mdOnSurface)

                Spacer().frame(height: 8)
                
                Text(model.theme.info)
                    .font(.subheadline)
                    .foregroundColor(.mdOnSurfaceVariant)
                    .lineLimit(2)
                    .truncationMode(.tail)
                
                Spacer().frame(height: 16)
                
                let progressTint = ProgressColor.getColor(
                    level: model.progressLevel
                )
                ProgressView(
                    value: Float(model.progressPercent),
                    total: 100.0
                )
                .progressViewStyle(
                    LinearProgressViewStyle(tint: progressTint)
                )
                .frame(height: 8)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                Spacer().frame(height: 16)

                buttonContainerContent
            }
            .padding()
        }
        .background(Color.mdSurface)
        .cornerRadius(12)
        .shadow(radius: 1)
        .onTapGesture {
            onStartClicked()
        }
    }
    
    @ViewBuilder
    var imageContent: some View {
        ZStack {
            if let imageName = model.theme.image, let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(aspectRatio, contentMode: .fit)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.systemGray6))
                    .aspectRatio(aspectRatio, contentMode: .fit)
                
                Text(
                    String(
                        model.theme.name.prefix(1)).uppercased()
                )
                .font(.largeTitle)
                .foregroundColor(.mdOnPrimaryContainer)
            }
        }
    }
    
    @ViewBuilder
    var buttonContainerContent: some View {
        HStack(spacing: 0) {
            Spacer()
            
            TonalButton(
                title: Text(
                    "theme_dialog_action_info",
                    tableName: appLocalizable
                ),
                action: {
                    onInfoClicked()
                }
            )
            
            Spacer().frame(width: 8)
            
            PrimaryButton(
                title: Text(
                    "design_system_action_game",
                    tableName: appLocalizable
                ),
                action: {
                    onStartClicked()
                }
            )
        }
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
    let model = ThemeUiModel(
        id: 1,
        theme: theme,
        progressPercent: 70,
        progressLevel: ProgressLevel.high
    )
    ThemeItem(model: model, onStartClicked: {}, onInfoClicked: {})
}
