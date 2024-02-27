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

class SectionViewCell: UICollectionViewCell, SectionViewCellProtocol {

    static let reuseIdentifier = "SectionCell"

    enum State {
        case lock
        case empty
        case low
        case normal
        case high
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var progressIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupCardView()
    }

    // MARK: - SectionViewCellProtocol

    func setNumTitle(id: Int) {
        titleLabel?.text = String(id)
    }

    func setProgressBar(level: SectionLevel) {
        switch level {
        case .empty:
            setupProgressBar(state: .empty)
        case .low:
            setupProgressBar(state: .low)
        case .normal:
            setupProgressBar(state: .normal)
        case .high:
            setupProgressBar(state: .high)
        }
    }

    func lockCell() {
        setupProgressBar(state: .lock)
    }

    // MARK: - Private func

    private func setupProgressBar(state: State) {
        setupTitleColor(isLock: (state == .lock))

        switch state {
        case .lock:
            setupIcon("lock.fill")
            setupColor(color: UIColor.secondaryLabel)
        case .empty:
            setupIcon("circle")
            setupColor(color: UIColor.label)
        case .low:
            setupIcon("largecircle.fill.circle")
            setupColor(color: ProgressColor.low)
        case .normal:
            setupIcon("largecircle.fill.circle")
            setupColor(color: ProgressColor.normal)
        case .high:
            setupIcon("largecircle.fill.circle")
            setupColor(color: ProgressColor.high)
        }
    }

    private func setupTitleColor(isLock: Bool) {
        if isLock {
            titleLabel?.textColor = UIColor.secondaryLabel
        } else {
            titleLabel?.textColor = UIColor.label
        }
    }

    private func setupIcon(_ imageName: String) {
        progressIcon?.image = UIImage(systemName: imageName)
    }

    private func setupColor(color: UIColor?) {
        progressContainerView?.tintColor = color
        progressContainerView?.backgroundColor = color?.withAlphaComponent(0.2)
    }

    private func setupCardView() {
        contentView.layer.cornerRadius = 10
    }
}
