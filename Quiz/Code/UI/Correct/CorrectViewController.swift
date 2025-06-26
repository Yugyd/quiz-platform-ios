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

class CorrectViewController: UIViewController {
    
    private var viewModel: CorrectViewModel!
        
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
        
        configuratePurchaseNotification()
        
        navigationItem.title = String(localized: "ds_navbar_title_correct", table: appLocalizable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.onAction(action: .loadData)
    }
    
    private func createHostController() -> UIHostingController<CorrectScreen> {
        viewModel = CorrectViewModel(
            repository: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        let view = CorrectScreen(
            onNavigateToGame: { [weak self] in
                self?.performSegue(withIdentifier: "segueCorrectToGame", sender: nil)
            },
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: - IBAction
    
    @IBAction func unwindToCorrectViewController(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinition = segue.destination as? GameViewController {
            destinition.hidesBottomBarWhenPushed = true
            destinition.sequeExtraArgs = GameSequeExtraArgs.Builder.with(mode: .error, themeId: Theme.defaultThemeId).build()
        }
    }
    
    // MARK: Notification center
    private func configuratePurchaseNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUi),
            name: NSNotification.Name.IAPHelperPurchaseNotification,
            object: nil
        )
    }
    
    @objc private func updateUi() {
        viewModel?.onAction(action: .loadData)
    }
}
