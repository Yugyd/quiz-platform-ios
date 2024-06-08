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
import SwiftyBeaver
import FirebaseRemoteConfig
import FirebaseCore

class AppRemoteConfigImpl: AppRemoteConfig {
    
    private let loggerTag = "AppRemoteConfigImpl"
    private let defaultPlistName = "remote_config_defaults"
    private let oneHour: Int = 3600
    
    private let logger: Logger
    private let remoteConfig: RemoteConfig?
    
    init(logger: Logger) {
        self.logger = logger
        
        if FirebaseApp.app() != nil {
            let remoteConfig = RemoteConfig.remoteConfig()
            
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = TimeInterval(oneHour)
            remoteConfig.configSettings = settings
            remoteConfig.setDefaults(fromPlist: defaultPlistName)
            
            self.remoteConfig = remoteConfig
        } else {
            self.remoteConfig = nil
        }
    }
    
    func fetchStringValue(key: String) -> String {
        fetchConfig()
        return getStringValue(key: key)
    }
    
    func fetchLongValue(key: String) -> Int {
        fetchConfig()
        return getLongValue(key: key)
    }
    
    func fetchBooleanValue(key: String) -> Bool {
        fetchConfig()
        return getBooleanValue(key: key)
    }
    
    private func getStringValue(key: String) -> String {
        let rawValue = remoteConfig?.configValue(forKey: key).stringValue ?? ""
        logger.print(
            tag: loggerTag,
            message: "New config value \(key): \(rawValue)"
        )
        return rawValue
    }

    private func getLongValue(key: String) -> Int {
        let rawValue = remoteConfig?.configValue(forKey: key).numberValue.intValue ?? 0
        logger.print(
            tag: loggerTag,
            message: "New config value \(key): \(rawValue)"
        )
        return rawValue
    }

    private func getBooleanValue(key: String) -> Bool {
        let rawValue = remoteConfig?.configValue(forKey: key).boolValue ?? false
        logger.print(
            tag: loggerTag,
            message: "New config value \(key): \(rawValue)"
        )
        return rawValue
    }
    
    private func fetchConfig() {
        remoteConfig?.fetchAndActivate(
            completionHandler: {status,_ in
                if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                    self.logger.print(
                        tag: self.loggerTag,
                        message: "Fetch config is successful"
                    )
                } else {
                    self.logger.print(
                        tag: self.loggerTag,
                        message: "Fetch config error"
                    )
                }
            }
        )
    }
}
