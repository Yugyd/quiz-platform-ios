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

class ErrorViewController: UIViewController, ErrorViewProtocol {
    
    private var viewModel: ErrorViewModel!
    
    var sequeExtraAiThemeArg: Int?
    var sequeExtraModeArg: Mode?
    var sequeExtraErrorIdsArg: Set<Int>?

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
        
        navigationItem.title = String(localized: "errors_title_error_list", table: appLocalizable)
    }
    
    private func createHostController() -> UIHostingController<ErrorScreen> {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let lineSepartorFormatter: LineSeparatorFormatter = IocContainer.app.resolve()
        
        viewModel = ErrorViewModel(
            repository: contentRepository,
            aiTasksInteractor: IocContainer.app.resolve(),
            questFormatter: lineSepartorFormatter,
            initialArgs: ErrorsInitialArgs(
                errorIds: sequeExtraErrorIdsArg!,
                mode: sequeExtraModeArg,
                aiThemeId: sequeExtraAiThemeArg
            ),
            logger: IocContainer.app.resolve()
        )
        
        let view = ErrorScreen(
            onBack: {
                self.navigationController?.popViewController(animated: true)
            },
            onNavigateToBrowser: { errorQuest in
                Web.searchInGoogle(error: errorQuest)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
