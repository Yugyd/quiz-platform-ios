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

import Alamofire

final class NetworkFactory {
        
    static let baseURL = URL(string: GlobalScope.content.apiUrl)!
    
    private let timeout: TimeInterval = 45
        
    func getSession() -> Session {
        let interceptor = HeaderRequestInterceptor()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        
        let eventMonitors: [EventMonitor] = [NetworkLogger()]
        
        return Session(
            configuration: configuration,
            interceptor: interceptor,
            eventMonitors: eventMonitors
        )
    }
}
