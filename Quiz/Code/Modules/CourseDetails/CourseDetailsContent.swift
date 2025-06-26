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
import MarkdownUI

struct CourseDetailsContent: View {
    let course: CourseDetailsDomainState
    let isActionsVisible: Bool
    let onTasksClicked: () -> Void

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {
                Markdown(
                    course.courseDetailModel?.content ?? ""
                )
                    .markdownTheme(.gitHub)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)

                ActionsFooter(
                    isActionsVisible: isActionsVisible,
                    onTasksClicked: onTasksClicked
                )
            }
            .padding(.top, 0)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.mdSurface)
    }
}

struct ActionsFooter: View {
    
    let isActionsVisible: Bool
    let onTasksClicked: () -> Void

    var body: some View {
        if isActionsVisible {
            Spacer().frame(height: 16)
           
            PrimaryButton(
                title: Text(
                    "course_details_start_test",
                    tableName: "AppLocalizable"
                ),
                action: onTasksClicked
            )
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    CourseDetailsContent(
        course: CourseDetailsDomainState(
            courseDetailModel: CourseDetailModel(
                id: 1,
                name: "Test",
                description: "Test",
                content: "## Markdown Example\nThis is **bold**.\n\n- Point 1\n- Point 2",
                icon: nil,
                parentCourseId: nil,
                isDetail: true
            ),
            isAiTasksEnabled: true
        ),
        isActionsVisible: true,
        onTasksClicked: {}
    )
}
