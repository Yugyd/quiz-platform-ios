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
            return NSLocalizedString("TITLE_SCHOOLBOY", comment: "Schoolboy")
        case .amateur:
            return NSLocalizedString("TITLE_AMATEUR", comment: "Amateur")
        case .student:
            return NSLocalizedString("TITLE_STUDENT", comment: "Student")
        case .master:
            return NSLocalizedString("TITLE_MASTER", comment: "Master")
        case .postgraduate:
            return NSLocalizedString("TITLE_POSTGRADUATE", comment: "Graduate student")
        case .candidate:
            return NSLocalizedString("TITLE_CANDIDATE", comment: "Candidate of science")
        case .doctor:
            return NSLocalizedString("TITLE_DOCTOR", comment: "PhD")
        case .professor:
            return NSLocalizedString("TITLE_PROFESSOR", comment: "Professor")
        case .academic:
            return NSLocalizedString("TITLE_ACADEMIC", comment: "Academic")
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
