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

import Foundation
import UIKit
import SwiftUI

private let segueNext = "segueProgressToPage"

class ProgressViewController: UIViewController, ProgressUpdateCallback {
    
    private var viewModel: ProgressViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = createHostController()
        let swiftUiView = hostingController.view!
        swiftUiView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(swiftUiView)
        
        NSLayoutConstraint.activate([
            swiftUiView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUiView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swiftUiView.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftUiView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        navigationItem.title = String(localized: "ds_navbar_title_progress", table: appLocalizable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAction(action: .loadData)
    }
    
    // MARK: ProgressUpdateCallback
    
    func update() {
        viewModel.onAction(action: .loadData)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let progress = sender as? ProgressUiModel else {
            return
        }
        
        if let parentDestinition = segue.destination as? UINavigationController {
            if let destinition = parentDestinition.viewControllers[0] as? ProgressPageViewController {
                destinition.hidesBottomBarWhenPushed = true
                destinition.sequeExtraThemeIdArg = progress.id
                destinition.updateCallback = self
                destinition.navigationItem.title = progress.title
            }
        }
    }
    
    // MARK: Private
    
    private func createHostController() -> UIHostingController<ProgressScreen> {
        viewModel = ProgressViewModel(
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        let view = ProgressScreen(
            onNavigateToSpecificProgress: { [weak self] progress in
                self?.performSegue(withIdentifier: segueNext, sender: progress)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
