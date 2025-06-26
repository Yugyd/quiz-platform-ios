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

class GlobalScope {

    enum State {
        case dev
    }

    static let state: State? = {
        switch Bundle.main.bundleIdentifier {
        case "com.yugyd.Quiz":
            return .dev
        default:
            return nil
        }
    }()

    static let content: Content = {
        switch state {
        case .dev:
            return Dev()
        case .none:
            fatalError("GlobalScope no valid init content")
        }
    }()

    // MARK: - Dev

    class Dev: Content {
        let apiUrl: String = "https://www.replaceme.com/api/"
        
        // Db
        let contentDbVersion = 3 // Old 2
        let proContentDbVersion = 3
        let userDbVersion = 1

        // Link
        let privacyPollicy = "https://sites.google.com/view/yugyd/privacy-policy/quiz-platform/"
        let appLink = "https://itunes.apple.com/app/REPLACE_ME"
        let telegramDomain = "quizplatformapp"

        // AdMob
        // DEV
        let kAppAdMobID: String = "ca-app-pub-3940256099942544~1458002511"
        let kGameBannerAdUnitID: String = "ca-app-pub-3940256099942544/2934735716"
        let kEndInterstitialAdUnitID: String = "ca-app-pub-3940256099942544/4411468910"
        var kGameRewardedAdUnitID: String = "ca-app-pub-3940256099942544/1712485313"

        // Title Over 3,000 questions and no ads!
        var contentPromo: String = String(localized: "pro_title_extended_content_info", table: appLocalizable)
    }
}

// MARK: - Content

protocol Content {
    var contentDbVersion: Int { get }
    var proContentDbVersion: Int { get }
    var userDbVersion: Int { get }

    var privacyPollicy: String { get }
    var appLink: String { get }
    var telegramDomain: String { get }

    /*
    App    ca-app-pub-3940256099942544~1458002511
    Banner    ca-app-pub-3940256099942544/2934735716
    Interstitial    ca-app-pub-3940256099942544/4411468910
    Interstitial Video    ca-app-pub-3940256099942544/5135589807
    Rewarded Video    ca-app-pub-3940256099942544/1712485313
    Native Advanced    ca-app-pub-3940256099942544/3986624511
    Native Advanced Video    ca-app-pub-3940256099942544/2521693316
    */
    // AdMob
    var kAppAdMobID: String { get }
    var kGameBannerAdUnitID: String { get }
    var kGameRewardedAdUnitID: String { get }
    var kEndInterstitialAdUnitID: String { get }

    // Title
    var contentPromo: String { get }
    
    // Network
    var apiUrl: String { get }
}
