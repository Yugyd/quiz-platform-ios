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

import SwiftUI

struct ContentErrorAlertFactory {
    
    func provideErrorMessage(errorMessage: ErrorMessageState) -> String {
        switch errorMessage {
        case .notAddedContentIsExists:
            return String(
                localized: "content_error_not_added_content_is_exists",
                table: appLocalizable
            )
        case .uriIsNull:
            return String(
                localized: "content_error_invalid_uri",
                table: appLocalizable
            )
        case .addIsFailed:
            return String(
                localized: "content_error_add_is_failed",
                table: appLocalizable
            )
        case .deleteIsFailed:
            return String(
                localized: "content_error_delete_is_failed",
                table: appLocalizable
            )
        case .notSelectAndDelete:
            return String(
                localized: "content_error_not_select_and_delete",
                table: appLocalizable
            )
        case .selectIsFailed:
            return String(
                localized: "content_error_select_is_failed",
                table: appLocalizable
            )
        case let .verifyError(error):
            return mapToMessage(error: error)
        case .oneItemNotDelete:
            return String(
                localized: "content_error_one_item_not_delete",
                table: appLocalizable
            )
        case .selectedItemNotDelete:
            return String(
                localized: "content_error_selected_item_not_delete",
                table: appLocalizable
            )
        case .contentFormatUrlNotLoaded:
            return String(
                localized: "content_error_content_format_url_not_loaded",
                table: appLocalizable
            )
        }
    }
    
    private func mapToMessage(error: ContentVerificationError) -> String {
        switch error {
        case let .duplicateIdQuests(message, quests):
            let quests = quests.map { String($0.id) }.joined(separator: ",")
            return String(
                localized: "content_format_error_content_quest_duplicate_id",
                table: appLocalizable
            ) + quests
        case let .duplicateIdThemes(message, themes):
            let themes = themes.map { String($0.id) }.joined(separator: ",")
            return String(
                localized: "content_format_error_content_theme_duplicate_id",
                table: appLocalizable
            ) + themes
        case let .notValidQuests(message, quests):
            let quests = quests.map { String($0.id) }.joined(separator: ",")
            return String(
                localized: "content_format_error_content_quest_not_valid",
                table: appLocalizable
            ) + quests
        case let .notValidThemes(message, themes):
            let themes = themes.map { String($0.id) }.joined(separator: ",")
            return String(
                localized: "content_format_error_content_theme_not_valid",
                table: appLocalizable
            ) + themes
        }
    }
}
