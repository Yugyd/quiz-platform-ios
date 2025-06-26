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
            
            PrimaryButton(
                title: Text(
                    "content_empty_state_button",
                    tableName: appLocalizable
                ),
                action: onChooseFileClicked
            )
            
            Spacer().frame(height: 8)
            
            TonalButton(
                title: Text(
                    "content_empty_state_button_data_format",
                    tableName: appLocalizable
                ),
                action: onDataFormatClicked
            )
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
