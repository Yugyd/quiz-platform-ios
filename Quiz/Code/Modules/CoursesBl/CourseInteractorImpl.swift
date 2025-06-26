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

final class CourseInteractorImpl: CourseInteractor {
    
    private let aiQuestInteractor: AiQuestInteractor
    private let courseInMemorySource: CourseInMemorySource
    private let queue = DispatchQueue(label: "CourseInteractorImpl.cacheQueue")
    
    init(
        aiQuestInteractor: AiQuestInteractor,
        courseInMemorySource: CourseInMemorySource
    ) {
        self.aiQuestInteractor = aiQuestInteractor
        self.courseInMemorySource = courseInMemorySource
    }
    
    func getCourses() async throws -> [CourseModel] {
        let themes = try await aiQuestInteractor.getThemes(parentThemeId: nil)
            .map { theme in
                CourseModel(
                    id: theme.id,
                    name: theme.name,
                    description: theme.description,
                    icon: theme.iconUrl,
                    parentCourseId: nil,
                    isDetail: theme.detail ?? false
                )
            }
        
        return queue.sync {
            courseInMemorySource.cachedCourses = themes
            return courseInMemorySource.cachedCourses
        }
    }
    
    func getCourses(parentCourseId: Int) async throws -> [CourseModel] {
        let themes = try await aiQuestInteractor.getThemes(parentThemeId: parentCourseId)
            .map { theme in
                CourseModel(
                    id: theme.id,
                    name: theme.name,
                    description: theme.description,
                    icon: theme.iconUrl,
                    parentCourseId: parentCourseId,
                    isDetail: theme.detail ?? false
                )
            }
        
        return queue.sync {
            var subCourses = courseInMemorySource.cachedSubCourses
            subCourses[parentCourseId] = themes
           
            courseInMemorySource.cachedSubCourses = subCourses
            return courseInMemorySource.cachedSubCourses[parentCourseId] ?? []
        }
    }
    
    func getCurrentCourse() async -> CourseDetailModel? {
        return queue.sync { courseInMemorySource.cachedCurrentCourse }
    }
    
    func setCurrentCourse(_ courseModel: CourseDetailModel) async {
        queue.sync { courseInMemorySource.cachedCurrentCourse = courseModel }
    }
    
    func getCourseDetails(courseId: Int) async throws -> CourseDetailModel {
        let themeDetail = try await aiQuestInteractor.getThemeDetail(themeId: courseId)
       
        return CourseDetailModel(
            id: themeDetail.id,
            name: themeDetail.name,
            description: themeDetail.description,
            content: themeDetail.content,
            icon: themeDetail.iconUrl,
            parentCourseId: nil,
            isDetail: themeDetail.detail
        )
    }
}
