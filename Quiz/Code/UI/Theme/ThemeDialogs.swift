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

struct InfoSheetView: View {
    let theme: Theme
    let onStartClicked: (Theme) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text(theme.name)
                .font(.title)
                .foregroundColor(Color.mdOnSurface)
            
            Spacer().frame(height: 8)
            
            Text(theme.info)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.mdOnSurfaceVariant)
            
            Spacer().frame(height: 16)

            PrimaryButton(
                title: Text(
                    "design_system_action_game",
                    tableName: appLocalizable
                ),
                matchParent: true,
                action: {
                    onStartClicked(theme)
                }
            )
            
            Spacer().frame(height: 8)

            TonalButton(
                title: Text(
                    "theme_action_close",
                    tableName: appLocalizable
                ),
                matchParent: true,
                action: {
                    onDismiss()
                }
            )
        }
        .padding()
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
    InfoSheetView(
        theme: theme,
        onStartClicked: { _ in },
        onDismiss: {}
    )
}
