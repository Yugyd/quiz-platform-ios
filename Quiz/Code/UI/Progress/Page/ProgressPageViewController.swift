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
import Combine

class ProgressPageViewController: UIViewController, ProgressPageSegueProtocol, ProgressPageViewProtocol {
    
    @IBOutlet weak var resetBarButtonItem: UIBarButtonItem!
    
    var sequeExtraThemeIdArg: Int?
    weak var updateCallback: ProgressUpdateCallback?
    
    private var viewModel: ProgressPageViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        viewModel.onAction(action: .loadData)
        
        bindViewModel()
    }
    
    // MARK: - Action binndera
    
    @IBAction func actionResetProgress(_ sender: UIBarButtonItem) {
        viewModel.onAction(action: .onResetClicked)
    }
    
    @IBAction func actionClosePage(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private func bindViewModel() {
        viewModel.$isResetButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.resetBarButtonItem.isEnabled = isEnabled
            }
            .store(in: &cancellables)
    }
    
    private func createHostController() -> UIHostingController<ProgressPageScreen> {
        viewModel = ProgressPageViewModel(
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            themeId: sequeExtraThemeIdArg!,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve(),
            updateCalback: updateCallback!
        )
        
        let view = ProgressPageScreen(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
