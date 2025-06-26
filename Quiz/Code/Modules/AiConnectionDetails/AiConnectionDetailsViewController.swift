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
import SwiftUI
import Combine

class AiConnectionDetailsViewController: UIViewController, AiConnectionDetailsViewProtocol {
    
    @IBOutlet weak var deleteBarButtonItem: UIBarButtonItem!
    
    var sequeExtraAiConnectionIdArg: String?
    
    // Keep a strong reference to the view model
    private var viewModel: AiConnectionDetailsViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = createHostController()
        let swiftUIView = hostingController.view!
        swiftUIView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(swiftUIView)
        NSLayoutConstraint.activate([
            swiftUIView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUIView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swiftUIView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swiftUIView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
        
        viewModel.onAction(.loadData)
        
        bindViewModel()
    }
    
    // MARK: - Binding
    
    @IBAction func actionDeleteProgress(_ sender: UIBarButtonItem) {
        viewModel.onAction(.onDeleteClicked)
    }
    
    @IBAction func actionClosePage(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private
    
    private func bindViewModel() {
        viewModel.$toolbarTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toolbarTitle in
                if let toolbarTitle = toolbarTitle {
                    switch toolbarTitle {
                    case .add:
                        self?.navigationItem.title = String(localized: "ai_connection_details_title_add", table: appLocalizable)
                    case .edit:
                        self?.navigationItem.title = String(localized: "ai_connection_details_title_edit", table: appLocalizable)
                    }
                } else {
                    self?.navigationItem.title = ""
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isDeleteVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDeleteVisible in
                if #available(iOS 16.0, *) {
                    self?.deleteBarButtonItem.isHidden = !isDeleteVisible
                } else {
                    self?.deleteBarButtonItem.isEnabled = isDeleteVisible
                }
            }
            .store(in: &cancellables)
    }
    
    private func createHostController() -> UIHostingController<AiConnectionDetailsScreen> {
        // Resolve dependencies, replace with your DI system or initializers
        let aiConnectionClient: AiConnectionClient = IocContainer.app.resolve()
        let aiRemoteConfigSource: AiRemoteConfigSource = IocContainer.app.resolve()
        let logger: Logger = IocContainer.app.resolve()
        
        viewModel = AiConnectionDetailsViewModel(
            aiConnectionClient: aiConnectionClient,
            aiRemoteConfigSource: aiRemoteConfigSource,
            logger: logger,
            aiConnectionId: sequeExtraAiConnectionIdArg
        )
        
        let view = AiConnectionDetailsScreen(
            viewModel: viewModel,
            onBack: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            },
            onNavigateToBrowser: { url in
                Web.openLink(link: url)
            }
        )
        
        return UIHostingController(rootView: view)
    }
}
