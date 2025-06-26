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

class ProfileInteractorImpl: ProfileInteractor {
    
    func getData(
        aiEnabled: Bool,
        aiConnection: String?,
    ) -> [ProfileItem] {
        var items: [ProfileItem] = []
        
        if !items.isEmpty {
            return items
        }
        
        // Header
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let header = ProfileItem(
            id: .header,
            row: HeaderProfileRow(
                appIcon: "icon_app",
                appName: appName ?? ""
            )
        )
        items.append(header)
     
        // Content
        let content = ProfileItem(
            id: .selectContent,
            row: ValueProfileRow(title: String(localized: "profile_title_content", table: appLocalizable))
        )
        items.append(content)
        
        // AI
        let aiSwitch = ProfileItem(
            id: .aiSwitcher,
            row: SwitchProfileRow(
                title: String(localized: "profile_title_enable_ai", table: appLocalizable),
            )
        )
        let aiConnectionItem: ProfileItem?
        if aiEnabled {
            if aiConnection != nil {
                aiConnectionItem = ProfileItem(
                    id: .aiConnection,
                    row: ValueProfileRow(
                        title: String(localized: "profile_title_ai", table: appLocalizable)
                    )
                )
            } else {
                aiConnectionItem = ProfileItem(
                    id: .aiConnection,
                    row: TextProfileRow(
                        title: String(localized: "profile_add_ai_connection", table: appLocalizable),
                    )
                )
            }
        } else {
            aiConnectionItem = nil
        }
        
        items.append(
            ProfileItem(
                id: .sectionAi,
                row: SectionProfileRow(title: String(localized: "profile_title_section_ai", table: appLocalizable))
            )
        )
        items.append(aiSwitch)
        if let aiConnectionItem = aiConnectionItem {
            items.append(aiConnectionItem)
        }
        
        // Social
        let telegram = ProfileItem(
            id: .telegram,
            row: TwoTextProfileRow(
                title: String(localized: "profile_title_telegram", table: appLocalizable),
                subtitle: String(localized: "profile_title_telegram_promo", table: appLocalizable),
            )
        )
        items.append(
            ProfileItem(
                id: .sectionSocial,
                row: SectionProfileRow(title: String(localized: "profile_title_social", table: appLocalizable))
            )
        )
        items.append(telegram)
        
        // Settings
        let transition = ProfileItem(
            id: .transition,
            row: ValueProfileRow(title: String(localized: "profile_title_show_answer", table: appLocalizable))
        )
        let sortQuest = ProfileItem(
            id: .sortQuest,
            row: SwitchProfileRow(
                title: String(localized: "profile_title_sorting_quest", table: appLocalizable),
            )
        )
        let vibration = ProfileItem(
            id: .vibration,
            row: SwitchProfileRow(
                title: String(localized: "profile_title_vibration", table: appLocalizable),
            )
        )
        items.append(
            ProfileItem(
                id: .sectionSettings,
                row: SectionProfileRow(title: String(localized: "profile_title_settings", table: appLocalizable))
            )
        )
        items.append(transition)
        items.append(sortQuest)
        items.append(vibration)
        
        // Link
        let rateApp = ProfileItem(
            id: .rateApp,
            row: TextProfileRow(title: String(localized: "profile_title_rate_app", table: appLocalizable))
        )
        let shareFriend = ProfileItem(
            id: .shareFriend,
            row: TextProfileRow(title: String(localized: "profile_title_share_app", table: appLocalizable))
        )
        let otherApps = ProfileItem(
            id: .otherApps,
            row: TextProfileRow(title: String(localized: "profile_title_other_apps", table: appLocalizable))
        )
        items.append(
            ProfileItem(
                id: .sectionPleaseUs,
                row: SectionProfileRow(title: String(localized: "profile_title_please_us", table: appLocalizable))
            )
        )
        items.append(rateApp)
        items.append(shareFriend)
        items.append(otherApps)
        
        // Feedback
        let reportError = ProfileItem(
            id: .reportError,
            row: TextProfileRow(title: String(localized: "profile_title_report_error", table: appLocalizable))
        )
        let privacyPollicy = ProfileItem(
            id: .privacyPollicy,
            row: TextProfileRow(title: String(localized: "profile_title_privacy_policy", table: appLocalizable))
        )
        items.append(
            ProfileItem(
                id: .sectionFeedback,
                row: SectionProfileRow(title: String(localized: "profile_title_feedback", table: appLocalizable))
            )
        )
        items.append(reportError)
        items.append(privacyPollicy)
        
        // Open-Source header
        let openSourceHeader = ProfileItem(
            id: .openSource,
            row: OpenSourceAppProfileRow(title: "")
        )
        items.append(openSourceHeader)
        
        return items
    }
}
