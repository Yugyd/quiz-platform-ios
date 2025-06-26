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

struct SectionItemView: View {
    
    let model: SectionUiModel
    let onTap: () -> Void
    
    var body: some View {
        CardView {
            VStack(spacing: 0) {
                // Top Section (Text)
                ZStack {
                    Color.clear
                    Text("\(model.id)")
                        .font(.largeTitle.bold())
                        .foregroundColor(.mdOnSurface)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .layoutPriority(2)
                
                // Bottom Section (Progress Indicator)
                ZStack {
                    progressColor.opacity(0.2)
                    Image(progressIconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(progressColor)
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .layoutPriority(1)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
    
    private var progressColor: Color {
        if model.positionState == .above {
            return .mdOnSurfaceVariant
        }
        
        switch model.item.level {
        case .empty: return .mdOnSurface
        case .low: return Color(uiColor: UIColor(named: "color_progress_low")!)
        case .normal: return Color(uiColor: UIColor(named: "color_progress_normal")!)
        case .high: return Color(uiColor: UIColor(named: "color_progress_high")!)
        }
    }
    
    private var progressIconName: String {
        if model.positionState == .above {
            return "ic_lock"
        }
        
        switch model.item.level {
        case .empty:
            return "ic_radio_button_unchecked"
        case .low, .normal, .high:
            return "ic_radio_button_checked"
        }
    }
}

#Preview {
    let section = Section(
        id: 1,
        count: 10,
        questIds: [1, 2],
        point: 5
    )
    let sectionWithLevel = SectionWithLevel(
        item: section,
        level: SectionLevel.normal
    )
    SectionItemView(
        model: SectionUiModel(
            id: 2,
            item: sectionWithLevel,
            positionState: SectionPositionState.below
        ),
        onTap: {}
    )
    .frame(width: 120, height: 120)
}
