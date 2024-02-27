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

class ProViewController: UIViewController, ProUpdateCallback {

    override func viewDidLoad() {
        super.viewDidLoad()

        enableGradientBackground()

        setupNavigationBar()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let parentDestinition = segue.destination as? SubscribeViewProtocol {
            parentDestinition.updateCallback = self
        }
    }

    // MARK: - ProUpdateCallback

    func update() {
        navigationController?.navigationBar.backgroundColor = .clear
        setupNavigationBar()
    }

    // MARK: - Private func

    private func enableGradientBackground() {
        let layer = CAGradientLayer()
        layer.frame = view.bounds

        let firstColor = UIColor(named: "color_gradient_blue_first")!.cgColor
        let endColor = UIColor(named: "color_gradient_blue_end")!.cgColor
        layer.colors = [firstColor, endColor]
        view.layer.insertSublayer(layer, at: 0)
    }

    private func setupNavigationBar() {
        if let bar = navigationController?.navigationBar {
            bar.setBackgroundImage(UIImage(), for: .default)
            bar.shadowImage = UIImage()
            bar.isTranslucent = true
        }
    }
}
