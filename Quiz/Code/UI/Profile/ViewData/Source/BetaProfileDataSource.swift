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

class BetaProfileDataSource: ProfileDataSourceProtocol {
    var sections: [SectionItem]
    
    private var items: Dictionary<SectionItem, [ProfileItem]>
    
    init() {
        self.sections = SectionItem.allCases
        self.items = Dictionary()
    }
    
    func getData() -> Dictionary<SectionItem, [ProfileItem]> {
        if !items.isEmpty {
            return items
        }
        
        items = Dictionary()
        
        // Content
        let content = ProfileItem(
            identifier: .selectContent,
            row: ValueProfileRow(title: NSLocalizedString("TITLE_CONTENT", comment: "Content"))
        )
        items.updateValue([content], forKey: SectionItem.top)
        
        // Social
        let telegram = ProfileItem(
            identifier: .telegram,
            row: TwoTextProfileRow(
                title: NSLocalizedString("PROFILE_TITLE_TELEGRAM", comment: "Telegram channel"),
                subtitle: NSLocalizedString("PROFILE_TITLE_TELEGRAM_PROMO", comment: "Daily questions and feedback")
            )
        )
        items.updateValue([telegram], forKey: SectionItem.social)
        
        // Purchase
        let pro = ProfileItem(
            identifier: .pro,
            row: TextProfileRow(
                title: NSLocalizedString("TITLE_PRO_VERSION", comment: "Pro version")
            )
        )
        let restorePurchase = ProfileItem(
            identifier: .restorePurchase,
            row: TextProfileRow(title: NSLocalizedString("TITLE_RESTORE_PURCHASE", comment: "Restore purchases"))
        )
        items.updateValue([pro/*, supportProject*/, restorePurchase], forKey: SectionItem.purchase)
        
        // Link
        let rateApp = ProfileItem(
            identifier: .rateApp,
            row: TextProfileRow(title: NSLocalizedString("TITLE_RATE_APP", comment: "Rate the app"))
        )
        let shareFriend = ProfileItem(
            identifier: .shareFriend,
            row: TextProfileRow(title: NSLocalizedString("TITLE_SHARE_FRIEND", comment: "Share app"))
        )
        let otherApps = ProfileItem(
            identifier: .otherApps,
            row: TextProfileRow(title: NSLocalizedString("TITLE_OTHER_APPS", comment: "Our applications"))
        )
        items.updateValue([rateApp, shareFriend, otherApps], forKey: SectionItem.link)
        
        // Settings
        let transition = ProfileItem(
            identifier: .transition,
            row: ValueProfileRow(title: NSLocalizedString("TITLE_SHOW_ANSWER", comment: "Viewing the answer"))
        )
        let sortQuest = ProfileItem(
            identifier: .sortQuest,
            row: SwitchProfileRow(
                title: NSLocalizedString("TITLE_SORTING_QUEST", comment: "Question sorting"),
                tag: SwitchProfileRow.sortingTag
            )
        )
        let vibration = ProfileItem(
            identifier: .vibration,
            row: SwitchProfileRow(
                title: NSLocalizedString("TITLE_VIBRATION", comment: "Vibration"),
                tag: SwitchProfileRow.vibrationTag
            )
        )
        items.updateValue([/*notification,*/ transition, sortQuest, vibration], forKey: SectionItem.settings)
        
        // Feedback
        let reportError = ProfileItem(
            identifier: .reportError,
            row: TextProfileRow(title: NSLocalizedString("TITLE_REPORT_ERROR", comment: "Report a bug"))
        )
        let privacyPollicy = ProfileItem(
            identifier: .privacyPollicy,
            row: TextProfileRow(title: NSLocalizedString("TITLE_PRIVACY_POLIICY", comment: "Privacy Policy"))
        )
        items.updateValue([reportError, privacyPollicy], forKey: SectionItem.feedback)
        
        // Open-Source header
        let openSourceHeader = ProfileItem(
            identifier: .openSource,
            row: OpenSourceAppProfileRow(title: "")
        )
        items.updateValue([openSourceHeader], forKey: .bottom)
        
        return items
    }
}
