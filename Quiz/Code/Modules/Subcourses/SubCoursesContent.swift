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

struct SubCourseListContent: View {
    
    let useParentType: Bool
    let items: [CourseModel]
    let courseBanner: ContinueCourseBannerUiModel?
    
    let onItemClicked: (CourseModel) -> Void
    let onBannerConfirmClicked: () -> Void
    let onBannerHideClicked: () -> Void
    
    var body: some View {
        List {
            if let banner = courseBanner {
                ContinueCourseCard(
                    courseTitle: banner.title,
                    onConfirmClicked: onBannerConfirmClicked,
                    onHideClicked: onBannerHideClicked
                )
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
                )
                .listRowSeparator(.hidden)
            }
            
            ForEach(items, id: \.id) { item in
                if useParentType {
                    CourseItem(
                        model: item,
                        onItemClicked: onItemClicked
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                } else {
                    SubCourseItem(
                        model: item,
                        onItemClicked: onItemClicked
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.inset)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}

#Preview {
    SubCourseListContent(
        useParentType: false,
        items: [
            CourseModel(
                id: 1,
                name: "SwiftUI Essentials",
                description: "Learn the fundamentals of SwiftUI.",
                icon: "swiftui-icon",
                parentCourseId: nil,
                isDetail: false
            ),
            CourseModel(
                id: 2,
                name: "Advanced Swift",
                description: "Master advanced features of Swift.",
                icon: "swift-icon",
                parentCourseId: 1,
                isDetail: true
            )
        ],
        courseBanner: ContinueCourseBannerUiModel(
            id: 100,
            title: "Resume your Swift journey"
        ),
        onItemClicked: { _ in },
        onBannerConfirmClicked: {},
        onBannerHideClicked: {}
    )
}
