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

import FirebaseCrashlytics

class CrashlyticsUtils {

    static func record(root: Swift.Error, isPrint: Bool? = nil, startMsg: String? = nil) {
        printError(root: root, isPrint: isPrint, startMsg: startMsg)

        Crashlytics.crashlytics().record(error: root)
    }

    static func record(root: Swift.Error, userInfo dict: [String: Any]?, isPrint: Bool? = nil) {
        printError(root: root, isPrint: isPrint, startMsg: nil)

        let nserror = root as NSError
        let error = NSError(domain: nserror.domain/*NSURLErrorDomain*/, code: nserror.code/*-1001*/, userInfo: dict)

        Crashlytics.crashlytics().record(error: error)
    }

    static func printError(root: Swift.Error, isPrint: Bool?, startMsg: String?) {
        guard let isPrint = isPrint, isPrint else {
            return
        }

        let nserror = root as NSError

        let msg: String
        if let startMsg = startMsg, !startMsg.isEmpty {
            msg = startMsg
        } else {
            msg = "Error is:"
        }

        print("\(msg) \(nserror), \(nserror.userInfo)")
    }
}
