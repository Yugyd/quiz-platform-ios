
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

struct CourseItem: View {
    let model: CourseModel
    let onItemClicked: (CourseModel) -> Void

    var body: some View {
        Button(action: {
            onItemClicked(model)
        }) {
            HStack(spacing: 0) {
                // Leading Icon
                Image("ic_book")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.mdOnSurface)

                Spacer().frame(width: 16)

                // Headline
                Text(model.name)
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                
                Spacer()
            }
            .padding(16)
            .background(Color.mdSurface)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SubCourseItem: View {
    let model: CourseModel
    let onItemClicked: (CourseModel) -> Void

    var body: some View {
        HStack {
            Text(model.name)
                .font(.body)
                .foregroundColor(.mdOnSurface)
            Spacer()
        }
        .padding(16)
        .background(Color.mdSurface)
        .contentShape(Rectangle())
        .onTapGesture {
            onItemClicked(model)
        }
    }
}

struct ContinueCourseCard: View {
   
    let courseTitle: String
    
    let onConfirmClicked: () -> Void
    let onHideClicked: () -> Void

    var body: some View {
        TwoLineWithActionsElevatedCard(
            title: courseTitle,
            subtitle: String(localized: "common_course_banner_title", table: appLocalizable),
            confirm: String(localized: "common_course_banner_continue", table: appLocalizable),
            cancel: String(localized: "common_course_banner_hide", table: appLocalizable),
            onConfirmClicked: onConfirmClicked,
            onCancelClicked: onHideClicked
        )
    }
}


#Preview {
    SubCourseItem(
        model: CourseModel(
            id: 1,
            name: "Name",
            description: "Descrtiption",
            icon: nil,
            parentCourseId: 2,
            isDetail: false
        ),
        onItemClicked: { _ in }
    )
    .previewLayout(.sizeThatFits)
}

#Preview {
    ContinueCourseCard(
        courseTitle: "Continue where you left off",
        onConfirmClicked: {},
        onHideClicked: {}
    )
    .previewLayout(.sizeThatFits)
}


#Preview {
    CourseItem(
        model: CourseModel(
            id: 1,
            name: "Introduction to SwiftUI",
            description: "Learn to build UI using SwiftUI",
            icon: nil,
            parentCourseId: nil,
            isDetail: false
        ),
        onItemClicked: { _ in }
    )
    .previewLayout(.sizeThatFits)
}
