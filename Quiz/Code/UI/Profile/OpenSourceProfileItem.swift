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

struct OpenSourceProfileItem: View {
    
    var onRatePlatformClicked: () -> Void
    var onReportBugPlatformClicked: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(
                "profile_content_banner_title",
                tableName: appLocalizable
            )
            .font(.title)
            .foregroundColor(Color.mdOnSurface)
            
            Spacer().frame(height: 16)
            
            Text(
                "profile_content_banner_subtitle",
                tableName: appLocalizable
            )
            .font(.body)
            .foregroundColor(Color.mdOnSurfaceVariant)
            
            Spacer().frame(height: 16)
            
            HStack {
                Spacer()
                
                PrimaryButton(
                    title: Text(
                        "profile_content_banner_rate",
                        tableName: appLocalizable
                    ),
                    action: onRatePlatformClicked
                )
            }
            
            Spacer().frame(height: 8)
            
            HStack {
                Spacer()
                
                TonalButton(
                    title: Text(
                        "profile_content_banner_report_error",
                        tableName: appLocalizable
                    )
                    ,
                    action: onReportBugPlatformClicked
                )
            }
        }
        .padding(16)
        .background(Color.mdSurface)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color.mdOutlineVariant,
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    OpenSourceProfileItem(
        onRatePlatformClicked: {},
        onReportBugPlatformClicked: {}
    )
}
