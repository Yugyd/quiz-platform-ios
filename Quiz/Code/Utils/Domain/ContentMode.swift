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

enum ContentMode {
    case pro

    var titleName: String {
        switch self {
        case .pro:
            return String(localized: "profile_title_pro_version", table: appLocalizable)
        }
    }

    var dbFileName: String {
        switch self {
        case .pro:
            return "content-encode-pro"
        }
    }

    var dbVersion: Int {
        switch self {
        case .pro:
            return GlobalScope.content.proContentDbVersion
        }
    }
}
