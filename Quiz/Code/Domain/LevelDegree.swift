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

enum LevelDegree {
    case schoolboy
    case amateur
    case student
    case master
    case postgraduate
    case candidate
    case doctor
    case professor
    case academic

    static let schoolboyValue = 15
    static let amateurValue = 30
    static let studentValue = 40
    static let masterValue = 50
    static let postgraduateValue = 60
    static let candidateValue = 70
    static let doctorValue = 80
    static let proffesorValue = 99
    static let academicValue = 100

    static func getTitle(levelDegree: LevelDegree) -> String {
        switch levelDegree {
        case .schoolboy:
            return String(localized: "progress_title_level_schoolboy", table: appLocalizable)
        case .amateur:
            return String(localized: "progress_title_level_amateur", table: appLocalizable)
        case .student:
            return String(localized: "progress_title_level_student", table: appLocalizable)
        case .master:
            return String(localized: "progress_title_level_master", table: appLocalizable)
        case .postgraduate:
            return String(localized: "progress_title_level_postgraduate", table: appLocalizable)
        case .candidate:
            return String(localized: "progress_title_level_candidate", table: appLocalizable)
        case .doctor:
            return String(localized: "progress_title_level_doctor", table: appLocalizable)
        case .professor:
            return String(localized: "progress_title_level_professor", table: appLocalizable)
        case .academic:
            return String(localized: "progress_title_level_academic", table: appLocalizable)
        }
    }

    static func instanceByProgress(progressPercent: Int) -> LevelDegree {
        if progressPercent < schoolboyValue {
            return schoolboy
        } else if progressPercent < amateurValue {
            return amateur
        } else if progressPercent < studentValue {
            return student
        } else if progressPercent < masterValue {
            return master
        } else if progressPercent < postgraduateValue {
            return postgraduate
        } else if progressPercent < candidateValue {
            return candidate
        } else if progressPercent < doctorValue {
            return doctor
        } else if progressPercent < proffesorValue {
            return professor
        } else {
            return academic
        }
    }
}
