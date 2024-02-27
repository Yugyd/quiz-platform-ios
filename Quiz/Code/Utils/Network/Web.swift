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

import UIKit

class Web {
    private static let googleSearchUrl = "https://www.google.ru/search?q="

    static func openLink(link: String) {
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    static func openTelegram(channelDomain: String) {
        let link = "https://t.me/\(channelDomain)"
        Web.openLink(link: link)
    }

    static func searchInGoogle(error: ErrorQuest) {
        let searchQuery = (error.quest + " " + error.trueAnswer).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let urlString = googleSearchUrl + (searchQuery ?? "")

        Web.openLink(link: urlString)
    }

    static func openRateApp() {
        let urlString = "\(GlobalScope.content.appLink)?mt=8&action=write-review"
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
