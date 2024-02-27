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

class AppHeaderView: UIView, AppHeaderViewProtocol {

    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var subscribeLabel: UILabel!

    func updateData(subscribeTitle: String, color: UIColor) {
        //appIcon?.image = UIImage(named: "AppIcon")

        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        appLabel?.text = appName

        subscribeLabel?.text = subscribeTitle
        subscribeLabel?.textColor = color
    }
}
