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

struct ProgressHeaderItemView: View {
    
    var model: ProgressHeaderUiModel
    
    var body: some View {
        VStack(spacing: 16) {
            let progressTint = ProgressColor.getColor(
                level: model.progressLevel
            )
            Image("ic_account_circle")
                .resizable()
                .frame(width: 96, height: 96)
                .foregroundColor(progressTint)
            
            Text(LevelDegree.getTitle(levelDegree: model.levelDegree))
                .font(.title2)
                .foregroundColor(progressTint)
                .multilineTextAlignment(.center)
            
            ProgressView(
                value: Float(model.progressPercent),
                total: 100.0
            )
            .progressViewStyle(
                LinearProgressViewStyle(tint: progressTint)
            )
            .frame(height: 8)
            .frame(minWidth: 100, maxWidth: 240)
            
            Text("\(model.progressPercent)%")
                .font(.body)
                .foregroundColor(Color.mdOnSurfaceVariant)
            
            Divider()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.mdSurface)
    }
}

struct ProgressItemView: View {
    
    var model: ProgressUiModel
    var onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.body)
                        .foregroundColor(.mdOnSurface)
                    
                    Text(model.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.mdOnSurfaceVariant)
                }
                
                Spacer()
                
                Text("\(model.value)%")
                    .font(.caption.bold())
                    .foregroundColor(model.progressColor)
            }
            .padding()
            .background(Color.mdSurface)
        }
        .background(Color.clear)
    }
}

struct ProgressHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressHeaderItemView(
            model: ProgressHeaderUiModel(
                progressPercent: 14,
                levelDegree: LevelDegree.academic,
                progressLevel: ProgressLevel.high
                
            )
        )
        .previewLayout(.sizeThatFits)
    }
}

struct ProgressItemView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressItemView(
            model: ProgressUiModel(
                id: 1,
                title: "Basics of Physics",
                subtitle: "Test",
                value: "40",
                progressColor: .mdPrimary
            ),
            onClick: {}
        )
        .previewLayout(.sizeThatFits)
    }
}
