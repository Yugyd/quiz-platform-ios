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

struct TwoLineWithActionsElevatedCard: View {
    
    let title: String
    let subtitle: String
    let confirm: String
    let cancel: String?

    let onConfirmClicked: () -> Void
    let onCancelClicked: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 36))
                .foregroundColor(.mdOnSurface)
           
            Text(subtitle)
                .font(.callout)
                .foregroundColor(.mdOnSurfaceVariant)
            
            HStack {
                Spacer()
              
                if let cancel = cancel, let onCancelClicked = onCancelClicked {
                    TonalButton(
                        title: Text(cancel),
                        action: onCancelClicked
                    )
                    
                    Spacer().frame(width: 8)
                }
                
                PrimaryButton(
                    title: Text(confirm),
                    action: onConfirmClicked
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.mdSurface)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        )
    }
}

#Preview {
    TwoLineWithActionsElevatedCard(
        title: "Title",
        subtitle: "Subtitle text goes here",
        confirm: "OK",
        cancel: "Cancel",
        onConfirmClicked: {},
        onCancelClicked: {}
    )
    .padding()
}
