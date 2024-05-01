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

struct ContentEmptyState: View {
    
    let onChooseFileClicked: () -> Void
    let onDataFormatClicked: () -> Void
    
    init(
        onChooseFileClicked: @escaping () -> Void,
        onDataFormatClicked: @escaping () -> Void
    ) {
        self.onChooseFileClicked = onChooseFileClicked
        self.onDataFormatClicked = onDataFormatClicked
    }
    
    var body: some View {
        VStack(alignment: .center) {
            IconWithBackground(
                size: 96,
                icon: "ic_file_open"
            )
            
            Spacer().frame(height: 32)
            
            Text(
                "content_empty_state_title",
                tableName: appLocalizable
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.mdOnBackground)
            .font(.title)
            
            Spacer().frame(height: 16)
            
            Text(
                "content_empty_state_message",
                tableName: appLocalizable
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.mdOnSurfaceVariant)
            .font(.body)
            
            Spacer().frame(height: 4)
            
            Text(
                "content_empty_state_note",
                tableName: appLocalizable
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.mdPrimary)
            .font(.body)
            
            Spacer().frame(height: 16)
            
            // Выделить в отдельный компонент
            Button(action: onChooseFileClicked) {
                Text(
                    "content_empty_state_button",
                    tableName: appLocalizable
                )
                .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: largeButtonCornerRadius))
            .controlSize(.large)
            .tint(Color.mdPrimary)
            
            Spacer().frame(height: 8)
            
            Button(action: onDataFormatClicked) {
                Text(
                    "content_empty_state_button_data_format",
                    tableName: appLocalizable
                )
                .font(.headline)
                .foregroundStyle(Color.mdOnSecondaryContainer)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: largeButtonCornerRadius))
            .controlSize(.large)
            .tint(Color.mdSecondaryContainer)
        }
        .padding(16)
    }
}

#Preview {
    ContentEmptyState(
        onChooseFileClicked: {
            print("onChooseFileClicked")
        },
        onDataFormatClicked: {
            print("onDataFormatClicked")
        }
    )
}
