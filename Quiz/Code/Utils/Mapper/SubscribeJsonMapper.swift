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

class SubscribeJsonMapper {
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func decode(json: String) -> SubscribeDate? {
        var subscribe: SubscribeDate? = nil
        do {
            if let jsonData = json.data(using: .utf8) {
                subscribe = try jsonDecoder.decode(SubscribeDate.self, from: jsonData)
            }
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Json decoder non parse: ")
        }
        return subscribe
    }

    func encode(subcribe: SubscribeDate) -> String? {
        let jsonData: Data?
        do {
            jsonData = try jsonEncoder.encode(subcribe)
        } catch {
            CrashlyticsUtils.record(root: error, isPrint: true, startMsg: "Json encoder non parse: ")
            jsonData = nil
        }
        if jsonData == nil || jsonData!.isEmpty {
            return nil
        }

        return String(data: jsonData!, encoding: .utf8)
    }
}
