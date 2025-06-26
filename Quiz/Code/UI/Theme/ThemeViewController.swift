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
import AppTrackingTransparency
import AdSupport

class ThemeViewController: UIViewController {

    private static let requestTrackingAuthorizationDelay = 1.0

    static let arcadeIndex = 0
    static let marathonIndex = 1
    static let sprintIndex = 2

    private weak var collectionController: ThemeSegmentedViewProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = String(localized: "ds_navbar_title_theme", table: appLocalizable)

        initCollectionController()

        requestIDFA()
    }

    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        var mode: Mode

        switch sender.selectedSegmentIndex {
        case ThemeViewController.arcadeIndex:
            mode = .arcade
        case ThemeViewController.marathonIndex:
            mode = .marathon
        case ThemeViewController.sprintIndex:
            mode = .sprint
        default:
            fatalError("No valid selected index in SegmentedControl")
        }

        collectionController?.changeMode(mode: mode)
    }

    @IBAction func unwindToThemeViewController(segue: UIStoryboardSegue) {

    }

    private func requestIDFA() {
        if #available(iOS 14, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + ThemeViewController.requestTrackingAuthorizationDelay, execute: {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    // Not use, recomend show ads
                })
            })
        }
    }

    private func initCollectionController() {
        if children.count > 0, let controller = children[0] as? ThemeSegmentedViewProtocol {
            collectionController = controller
        }
    }
}
