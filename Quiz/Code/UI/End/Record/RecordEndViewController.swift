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

private let segueNext = "segueRecordToEnd"

class RecordEndViewController: UIViewController, EndViewProtocol {
    
    var sequeExtraArgs: EndSequeExtraArgs?
    
    private var viewModel: RecordEndViewModel!
        
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
    
    private func createHostController() -> UIHostingController<RecordEndScreen> {
        viewModel = RecordEndViewModel(
            featureManager: IocContainer.app.resolve(),
            remoteConfigRepository: IocContainer.app.resolve(),
            mode: sequeExtraArgs!.gameMode,
            logger: IocContainer.app.resolve()
        )
        
        let view = RecordEndScreen(
            onNavigateToGameEnd: { [weak self] in
                self?.performSegue(withIdentifier: segueNext, sender: self?.sequeExtraArgs)
            },
            onNavigateToRate: {
                Web.openRateApp()
            },
            onNavigateToTelegram: {
                Web.openTelegram(channelDomain: GlobalScope.content.telegramDomain)
            },
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sequeData = sender as? EndSequeExtraArgs else {
            return
        }

        if let destinition = segue.destination as? UIViewController & EndViewProtocol {
            destinition.sequeExtraArgs = sequeData
        }
    }
}
