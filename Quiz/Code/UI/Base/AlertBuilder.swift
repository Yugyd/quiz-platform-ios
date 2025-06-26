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

class AlertBuilder {

    private let alert: UIAlertController

    private init(alert: UIAlertController) {
        self.alert = alert
    }

    func setTitle(_ title: String) -> AlertBuilder {
        alert.title = title
        return self
    }

    func setMsg(_ message: String) -> AlertBuilder {
        alert.message = message
        return self
    }

    func setAction(title: String? = nil, style: UIAlertAction.Style? = nil, handler: ((UIAlertAction) -> Void)? = nil) -> AlertBuilder {
        let action: UIAlertAction
        if let title = title, let style = style {
            action = UIAlertAction(title: title, style: style, handler: handler)
        } else if let title = title {
            action = UIAlertAction(title: title, style: .default, handler: handler)
        } else {
            action = UIAlertAction(title: String(localized: "ds_ok", table: appLocalizable), style: .default, handler: handler)
        }

        alert.addAction(action)
        return self
    }

    func build() -> UIAlertController {
        return alert
    }

    static func with() -> AlertBuilder {
        return AlertBuilder(alert: UIAlertController(title: nil, message: nil, preferredStyle: .alert))
    }
}
