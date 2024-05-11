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
import FirebaseRemoteConfig

class ContentRemoteConfigSourceImpl: ContentRemoteConfigSource {
    private let contentFormatUrlKey = "content_format_url"
    
    private let remoteConfig: AppRemoteConfig
    
    init(remoteConfig: AppRemoteConfig) {
        self.remoteConfig = remoteConfig
    }
    
    func getContentFormatUrl() async -> String {
        // TODO: Delete mock url after integrate Remote Config
        let contentFormatUrl = if true { "https://github.com/Yugyd/quiz-platform/blob/master/docs/CONTENT_FORMAT.md" } else { remoteConfig.fetchStringValue(key: contentFormatUrlKey) }
        return contentFormatUrl
    }
}
