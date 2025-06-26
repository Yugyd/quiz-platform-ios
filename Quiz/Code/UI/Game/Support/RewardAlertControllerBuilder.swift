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

import MaterialComponents.MaterialDialogs

class RewardAlertControllerBuilder {
    private let title = String(localized: "game_title_add_life", table: appLocalizable)
    private let message = String(localized: "game_msg_add_life", table: appLocalizable)
    private let next = String(localized: "game_action_next", table: appLocalizable).uppercased()
    private let extraLife = String(localized: "game_action_watch", table: appLocalizable).uppercased()

    let alertController: MDCAlertController

    init() {
        alertController = MDCAlertController(title: title, message: message)
    }

    @discardableResult
    static func with() -> RewardAlertControllerBuilder {
        return RewardAlertControllerBuilder()
    }

    @discardableResult
    func addAgreeAction(handler: MDCActionHandler?) -> RewardAlertControllerBuilder {
        let action = MDCAlertAction(title: next, emphasis: .high, handler: handler)
        alertController.addAction(action)
        return self
    }

    @discardableResult
    func addCancelAction(handler: MDCActionHandler?) -> RewardAlertControllerBuilder {
        let action = MDCAlertAction(title: extraLife, emphasis: .high, handler: handler)
        alertController.addAction(action)
        return self
    }

    func build() -> MDCAlertController {
        setupTheme()
        return alertController
    }

    // MARK: - Private func

    private func setupTheme() {
        //alertController.mdc_dialogPresentationController?.dismissOnBackgroundTap = false
        alertController.mdc_dialogPresentationController?.dialogCornerRadius = CGFloat(8)

        alertController.backgroundColor = .systemBackground
        alertController.titleColor = .label
        alertController.messageColor = .secondaryLabel
        if let btnCancel = alertController.button(for: alertController.actions[0]) {
            btnCancel.setTitleColor(.label, for: .normal)
        }
        if let btnCancel = alertController.button(for: alertController.actions[1]) {
            btnCancel.setTitleColor(.systemBlue, for: .normal)
        }
    }
}
