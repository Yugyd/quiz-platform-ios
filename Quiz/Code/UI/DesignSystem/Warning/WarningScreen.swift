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

struct WarningScreen: View {
    
    @Binding var isRetryButtonEnabled: Bool
    let onRetryClicked: (() -> Void)?
    
    var body: some View {
        VStack {
            Image("ic_cloud_off")
                .resizable()
                .frame(width: 64, height: 64)
                .foregroundColor(Color.mdOnBackground)
            
            Spacer().frame(height: 48)
            
            Text(
                "design_system_title_empty_state",
                tableName: appLocalizable
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.mdOnBackground)
            .font(.title)
            
            Spacer().frame(height: 8)
            
            Text(
                "design_system_title_empty_state_description",
                tableName: appLocalizable
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.mdOnSurfaceVariant)
            .font(.body)
            
            if isRetryButtonEnabled {
                Spacer().frame(height: 16)
                
                PrimaryButton(
                    title: .constant(
                        Text(
                            "design_system_title_empty_state_retry",
                            tableName: appLocalizable
                        )
                    ),
                    action:{
                        self.onRetryClicked?()
                    }
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WarningScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WarningScreen(
                isRetryButtonEnabled: .constant(true),
                onRetryClicked: {}
            )
            
            WarningScreen(
                isRetryButtonEnabled: .constant(false),
                onRetryClicked: {}
            )
        }
    }
}
