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

class AnswerButton: UIButton, AnswerButtonProtocol {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSize()
    }

    override var intrinsicContentSize: CGSize {
        let size = self.titleLabel!.intrinsicContentSize
        return CGSize(width: size.width + contentEdgeInsets.left + contentEdgeInsets.right, height: size.height + contentEdgeInsets.top + contentEdgeInsets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
    }

    // MARK: - AnswerButtonProtocol

    func highlight(state: HighlightState) {
        switch state {
        case .trueState: setupTitleColor(color: ProgressColor.high)
        case .falseState: setupTitleColor(color: ProgressColor.low)
        case .clearState: setupTitleColor(color: ProgressColor.normal)
        }
    }

    // MARK: - Private func

    private func setupSize() {
        self.titleLabel?.numberOfLines = 0
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
        self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
    }

    private func setupTitleColor(color: UIColor) {
        setTitleColor(color, for: .normal)
        setTitleColor(color, for: .disabled)
    }
}
