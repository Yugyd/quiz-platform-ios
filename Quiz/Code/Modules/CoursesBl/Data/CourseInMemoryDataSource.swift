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

// Thread-safety via serial queue
final class CourseInMemoryDataSource: CourseInMemorySource {
   
    private let queue = DispatchQueue(label: "CourseInMemoryDataSource.queue")
    
    private var _cachedCourses: [CourseModel] = []
    private var _cachedSubCourses: [Int: [CourseModel]] = [:]
    private var _cachedCurrentCourse: CourseDetailModel? = nil
    
    var cachedCourses: [CourseModel] {
        get { queue.sync { _cachedCourses } }
        set { queue.sync { _cachedCourses = newValue } }
    }
    
    var cachedSubCourses: [Int: [CourseModel]] {
        get { queue.sync { _cachedSubCourses } }
        set { queue.sync { _cachedSubCourses = newValue } }
    }
    
    var cachedCurrentCourse: CourseDetailModel? {
        get { queue.sync { _cachedCurrentCourse } }
        set { queue.sync { _cachedCurrentCourse = newValue } }
    }
}
