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

/**
 * Отображает карточку темы.
 */
class ThemeViewCell: UICollectionViewCell, ThemeViewCellProtocol {

    static let reuseIdentifier = "ThemeCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCardView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        titleLabel.text = nil

        progressView.setProgressColor(progress: 0)
        progressView.setProgress(0, animated: false)
    }

    // MARK: - ThemeViewCellProtocol

    func updateData(image: String, title: String, progress: Int) {
        imageView?.image = UIImage(named: image)
        titleLabel?.text = title
        progressView?.setProgressColor(progress: progress)
        progressView?.setProgress(progress, animated: true)
    }

    // MARK: - Private func

    private func setupCardView() {
        contentView.layer.cornerRadius = 20.0
    }
}
