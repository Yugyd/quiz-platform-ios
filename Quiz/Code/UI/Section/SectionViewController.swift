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

private let segueSectionToGame = "segueSectionToGame"

class SectionViewController: UIViewController, SectionSegueProtocol {
    
    var sequeExtraThemeIdArg: Int?

    private var viewModel: SectionViewModel!

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAction(action: .loadData)
    }

    // MARK: - Navigation
        
    @IBAction func unwindToSectionViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sectionSenderArgs = sender as? SectionSenderArgs else {
            return
        }
        
        let section = sectionSenderArgs.section
        let theme = sectionSenderArgs.theme
        
        if let destinition = segue.destination as? GameViewController {
            destinition.hidesBottomBarWhenPushed = true
            destinition.sequeExtraArgs = GameSequeExtraArgs.Builder
                .with(mode: .arcade, themeId: theme.id)
                .setSectionId(sectionId: section.id)
                .setRecord(record: section.point)
                .build()
        }
    }
    
    // MARK: Private
    
    private func createHostController() -> UIHostingController<SectionScreen> {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        
        viewModel = SectionViewModel(
            contentRepository: contentRepository,
            userRepository: userRepository,
            themeId: sequeExtraThemeIdArg!,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        let view = SectionScreen(
            onNavigateToGame: { [weak self] args in
                self?.performSegue(withIdentifier: segueSectionToGame, sender: args)
            },
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}

