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

struct ProfileListContent: View {
    
    let items: [ProfileItem]
    
    let contentTitle: String
    let isSorting: Bool
    let isVibration: Bool
    let transition: String
    let versionTitle: String
    
    let aiEnabled: Bool
    let aiConnection: String?

    let onItemClicked: (ProfileItem) -> Void
    let onItemChecked: (ProfileItem, Bool) -> Void
    let onRatePlatformClicked: () -> Void
    let onReportBugPlatformClicked: () -> Void
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                ProfileItemView(
                    model: item,
                    contentTitle: contentTitle,
                    isSorting: isSorting,
                    isVibration: isVibration,
                    transition: transition,
                    versionTitle: versionTitle,
                    aiEnabled: aiEnabled,
                    aiConnection: aiConnection,
                    onItemClicked: onItemClicked,
                    onItemChecked: onItemChecked,
                    onRatePlatformClicked: onRatePlatformClicked,
                    onReportBugPlatformClicked: onReportBugPlatformClicked
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .background(Color.mdSurface)
    }
}

struct ProfileListContent_Previews: PreviewProvider {
    static var previews: some View {
        // Создаем тестовые данные
        let testItems = [
            ProfileItem(
                id: .restorePurchase,
                row: TextProfileRow(title: "Настройки")
            ),
            ProfileItem(
                id: .rateApp,
                row: TextProfileRow(title: "Оценить приложение")
            )
        ]
        
        ProfileListContent(
            items: testItems,
            contentTitle: "Content",
            isSorting: true,
            isVibration: true,
            transition: "Transition",
            versionTitle: "Version",
            aiEnabled: true,
            aiConnection: "AI Connection",
            onItemClicked: { _ in },
            onItemChecked: { _, _ in },
            onRatePlatformClicked: {},
            onReportBugPlatformClicked: {}
        )
    }
}
