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
import SwiftUI

class ContentViewController: UIViewController, ContentViewProtocol {
    
    var isBackEnabled: Bool = false
    
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
    }
    
    private func createHostController() -> UIHostingController<ContentScreen> {
        let viewModel = ContentViewModel(
            interactor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve(),
            isBackEnabled: isBackEnabled
        )
        
        let view = ContentScreen(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onSwitchToMainStoryboard: { [weak self] in
                // Assuming SceneDelegate is managing the window
                let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate
                sceneDelegate?.contentDidComplete()
            },
            onNavigateToBrowser: { url in
                Web.openLink(link: url)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
