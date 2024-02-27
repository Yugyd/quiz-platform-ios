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

class ModeViewCell: UITableViewCell, ModeViewCellProtocol {

    static let reuseIdentifier = "ProgressModeCell"

    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    func updateData(title: String, progressPercent: Int, progressTitle: String?) {
        modeLabel?.text = title
        progressView?.setProgress(progressPercent, animated: true)
        progressLabel?.text = progressTitle
    }
}
