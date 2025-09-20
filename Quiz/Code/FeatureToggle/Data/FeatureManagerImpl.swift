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

class FeatureManagerIml: FeatureManager {
    
    private var remoteConfig: RemoteConfig
    
    init(
        remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    ) {
        self.remoteConfig = remoteConfig
        self.remoteConfig.configSettings = RemoteConfigSettings()
        
        // Set default values for feature flags and the force update version
        let defaultValues: [String: NSObject] = [
            FeatureToggle.ad.rawValue: false as NSObject,
            FeatureToggle.aiTasks.rawValue: false as NSObject,
            FeatureToggle.telegram.rawValue: false as NSObject,
        ]
        
        self.remoteConfig.setDefaults(defaultValues)
    }
    
    func fetchRemoteConfig(completion: @escaping (Bool) -> Void) {
        remoteConfig.fetchAndActivate { fetchStatus, error in
            if fetchStatus == .successFetchedFromRemote || fetchStatus == .successUsingPreFetchedData {
                print("Remote config: fetched")
                completion(true)
            } else {
                print("Remote config: Error fetching \(error?.localizedDescription ?? "Unknown error")")
                
                completion(false)
            }
        }
    }
    
    func isFeatureEnabled(_ feature: FeatureToggle) -> Bool {
        let isEnabled = remoteConfig[feature.rawValue].boolValue
        print("Feature toggle: \(feature.rawValue), \(isEnabled)")
        return remoteConfig[feature.rawValue].boolValue
    }
    
    func getForceUpdateVersion() -> Int {
        let forceUpdate = remoteConfig["force_update_version"].numberValue.intValue
        print("Force update: \(forceUpdate)")
        return forceUpdate
    }
}
