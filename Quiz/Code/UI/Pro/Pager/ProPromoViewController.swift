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

class ProPromoViewController: UIViewController {

    @IBOutlet weak var promoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var index: Int = 0
    var data: PromoViewData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fillViews()
    }

    func setupViews() {
        titleLabel?.textColor = UIColor.white
        subtitleLabel?.textColor = UIColor.white.withAlphaComponent(0.8)
    }

    func fillViews() {
        if let imageName = data?.imageQualifier {
            promoImage?.image = UIImage(named: imageName)
        }
        titleLabel?.text = data?.title
        subtitleLabel?.text = data?.subtitle
    }
}
