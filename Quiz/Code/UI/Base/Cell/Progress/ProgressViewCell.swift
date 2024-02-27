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

class ProgressViewCell: UITableViewCell, ProgressViewCellProtocol {

    static let reuseIdentifier = "ProgressCell"

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!

    func updateData(title: String, levelDegree: String, progressPercent: Int) {
        themeLabel?.text = title
        levelLabel?.text = levelDegree
        percentLabel?.text = "\(progressPercent)%"
        progressView?.setProgress(progressPercent, animated: true)
    }
}
