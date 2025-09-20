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
import AppTrackingTransparency
import SwiftUI

private let segueNext = "segueEndToError"
private let unwindToTheme = "unwindToThemeViewController"
private let unwindToCorrect = "unwindToCorrectViewController"
private let unwindToSection = "unwindToSectionViewController"
private let unwindToCourseDetails = "unwindToCourseDetailsViewController"

class GameEndViewController: UIViewController, EndViewProtocol {
    
    var sequeExtraArgs: EndSequeExtraArgs?
    
    private var viewModel: GameEndViewModel!
    private var featureManager: FeatureManager!
    
    private var isFinish = false
    
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
        
        requestIdfaAndLoadAd()
    }
    
    private func createHostController() -> UIHostingController<GameEndScreen> {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        featureManager = IocContainer.app.resolve()
        
        let data = ProgressEnd(
            mode: sequeExtraArgs!.gameMode,
            themeId: sequeExtraArgs!.themeId,
            point: sequeExtraArgs!.point,
            count: sequeExtraArgs!.count,
            errorQuestIds: sequeExtraArgs!.errorQuestIds
        )
        let isRewardedOpen = sequeExtraArgs!.isRewardedSuccess
        
        viewModel = GameEndViewModel(
            contentRepository: contentRepository,
            userRepository: userRepository,
            data: data,
            isRewardedOpen: isRewardedOpen,
            logger: IocContainer.app.resolve(),
            featureManager: featureManager,
            courseInteractor: IocContainer.app.resolve()
        )
        
        let view = GameEndScreen(
            onNavigateToErrorsList: { [weak self] args in
                self?.performSegue(withIdentifier: segueNext, sender: args)
            },
            onNaviateToGame: { [weak self] mode, isRewardedSuccess in
                if self?.isShowAd(isRewardedSuccess: isRewardedSuccess) == true {
                    // TODO Add new ad manager
                } else {
                    self?.startNewGame(mode: mode)
                }
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    func startNewGame(mode: Mode) {
        guard !isFinish else {
            return
        }
        
        isFinish = true
        
        switch mode {
        case .arcade:
            performSegue(withIdentifier: unwindToSection, sender: nil)
        case .error:
            performSegue(withIdentifier: unwindToCorrect, sender: nil)
        case .marathon, .sprint:
            performSegue(withIdentifier: unwindToTheme, sender: nil)
        case .aiTasks:
            performSegue(withIdentifier: unwindToCourseDetails, sender: nil)
        case .unused: fatalError()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == unwindToTheme
            || segue.identifier! == unwindToCorrect
            || segue.identifier! == unwindToSection
            || segue.identifier! == unwindToCourseDetails {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        } else if segue.identifier! == segueNext {
            guard let sequeData = sender as? ErrorsInitialArgs else {
                return
            }
            
            if let destinition = (segue.destination as? UINavigationController)?.viewControllers[0] as? ErrorViewProtocol {
                destinition.sequeExtraErrorIdsArg = sequeData.errorIds
                destinition.sequeExtraModeArg = sequeData.mode
                destinition.sequeExtraAiThemeArg = sequeData.aiThemeId
            }
        }
    }
    
    private func requestIdfaAndLoadAd() {
        guard isAdEnabled() else {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                })
            }
            return
        }
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.createAndLoadAd()
                }
            })
        } else {
            createAndLoadAd()
        }
    }
    
    private func createAndLoadAd() {
        // TODO Add new ad manager
    }
    
    private func isAdEnabled() -> Bool {
        let mode: ContentMode = IocContainer.app.resolve()
        return featureManager?.isFeatureEnabled(FeatureToggle.ad) == true && mode != .pro
    }
    
    private func isShowAd(isRewardedSuccess: Bool) -> Bool {
        return isAdEnabled() && isRewardedSuccess == false
    }
}
