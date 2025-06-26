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

private let segueThemeToGame = "segueThemeToGame"
private let segueThemeToSection = "segueThemeToSection"

class ThemeCollectionViewController: UIViewController, ThemeSegmentedViewProtocol {
    
    private var viewModel: ThemeViewModel!
    
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
    
    // MARK: ThemeSegmentedViewProtocol
    
    func changeMode(mode: Mode) {
        viewModel.onAction(action: .onGameModeChanged(mode))
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let themeSenderArgs = sender as? ThemeSenderArgs else {
            return
        }
        
        if segue.identifier == segueThemeToGame {
            if let destinition = segue.destination as? GameViewController {
                destinition.hidesBottomBarWhenPushed = true
                
                destinition.sequeExtraArgs = GameSequeExtraArgs.Builder
                    .with(mode: themeSenderArgs.gameMode, themeId: themeSenderArgs.theme.id)
                    .setRecord(record: themeSenderArgs.record)
                    .build()
            }
        } else if segue.identifier == segueThemeToSection {
            if let destinition = segue.destination as? (UIViewController & SectionSegueProtocol) {
                var mutableDestination = destinition
                mutableDestination.sequeExtraThemeIdArg = themeSenderArgs.theme.id
                mutableDestination.navigationItem.title = themeSenderArgs.theme.name
            }
        }
    }
    
    // MARK: Private
    
    private func createHostController() -> UIHostingController<ThemeScreen> {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        
        viewModel = ThemeViewModel(
            contentRepository: contentRepository,
            userRepository: userRepository,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        let view = ThemeScreen(
            onNavigateToGame: { [weak self] themeArgs in
                self?.performSegue(withIdentifier: segueThemeToGame, sender: themeArgs)
            },
            onNavigateToSection: { [weak self] themeArgs in
                self?.performSegue(withIdentifier: segueThemeToSection, sender: themeArgs)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
}
