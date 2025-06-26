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

private let segueProfileToPro = "segueProfileToPro"
private let segueProfileToTransition = "segueProfileToTransition"
private let segueProfileToReport = "segueProfileToReport"
private let segueProfileToContent = "segueProfileToContent"
private let segueProfileToAiConnection = "segueProfileToAiConnection"

class ProfileViewController: UIViewController {
    
    private var viewModel: ProfileViewModel!
    
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
        
        navigationItem.title = String(localized: "ds_navbar_title_profile", table: appLocalizable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.onAction(action: .loadData)
    }
    
    // MARK: Private
    
    private func createHostController() -> UIHostingController<ProfileScreen> {
        let userPreferences: UserPreferences = IocContainer.app.resolve()
        
        viewModel = ProfileViewModel(
            preferences: userPreferences,
            iapHelper: IocContainer.app.resolve(),
            profileInteractor: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve(),
            aiConnectionClient: IocContainer.app.resolve()
        )
        
        let view = ProfileScreen(
            onNavigateToProOnboarding: { [weak self] in
                self?.performSegue(withIdentifier: segueProfileToPro, sender: nil)
            },
            onNavigateToTransition: { [weak self] in
                self?.performSegue(withIdentifier: segueProfileToTransition, sender: nil)
            },
            onNavigateToAppStore: {
                Web.openRateApp()
            },
            onNavigateToShare: { [weak self] in
                self?.shareFriend()
            },
            onNavigateToOtherApps: {
                Web.openLink(link: StaticScope.devLink)
            },
            onNavigateToExternalReportError: { [weak self] in
                self?.performSegue(withIdentifier: segueProfileToReport, sender: nil)
            },
            onNavigateToPrivacyPolicy: {
                Web.openLink(link: GlobalScope.content.privacyPollicy)
            },
            onNavigateToContents: { [weak self] in
                self?.performSegue(withIdentifier: segueProfileToContent, sender: nil)
            },
            onNavigateToExternalPlatformReportError: {
                Web.openLink(link: StaticScope.quizPlatformIssues)
            },
            onNavigateToExternalPlatformRate: {
                Web.openLink(link: StaticScope.quizPlatformProject)
            },
            onNavigateToTelegramChannel: {
                Web.openTelegram(channelDomain: GlobalScope.content.telegramDomain)
            },
            onNavigateToAiConnection: { [weak self] id in
                self?.performSegue(withIdentifier: segueProfileToAiConnection, sender: id)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: Private share funcs
    
    private func shareFriend() {
        if let link = URL(string: GlobalScope.content.appLink) {
            let objectsToShare = [link]
            let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                      applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                setupActivityViewController(activityViewController: activityVC)
            }
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    private func setupActivityViewController(activityViewController: UIActivityViewController) {
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
    }
    
    // MARK: Private Notification Center
    private func configurateNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUi), name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoreAlert(_:)), name: NSNotification.Name.IAPHelperRestoreNotification, object: nil)
    }
    
    @objc func updateUi() {
        viewModel.onAction(action: .loadData)
    }
    
    @objc func showRestoreAlert(_ notification: Notification) {
        if let isRestored = notification.userInfo?[IAPSwiftHelper.keyRestoreNotificationUserInfo] as? Bool {
            let alert: UIAlertController
            
            let actionTitle = String(localized: "profile_restore_purchase_alert_action", table: appLocalizable)
            if isRestored {
                alert = AlertBuilder
                    .with()
                    .setTitle(
                        String(localized: "profile_restore_purchase_alert_title", table: appLocalizable)
                    )
                    .setMsg(
                        String(localized: "profile_restore_purchase_alert_msg", table: appLocalizable)
                    )
                    .setAction(title: actionTitle)
                    .build()
            } else {
                alert = AlertBuilder
                    .with()
                    .setTitle(
                        String(localized: "profile_restore_purchase_alert_error_title", table: appLocalizable)
                    )
                    .setMsg(
                        String(localized: "profile_restore_purchase_alert_error_msg", table: appLocalizable)
                    )
                    .setAction(title: actionTitle)
                    .build()
            }
            if presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == segueProfileToTransition {
            segue.destination.navigationItem.title = String(
                localized: "profile_title_show_answer",
                table: appLocalizable
            )
        } else if segue.identifier! == segueProfileToContent {
            let destinition = segue.destination as? UIViewController & ContentViewProtocol
            destinition?.isBackEnabled = true
        } else if segue.identifier! == segueProfileToAiConnection {
            if let parentDestinition = segue.destination as? UINavigationController {
                if let destinition = parentDestinition.viewControllers[0] as? AiConnectionDetailsViewProtocol {
                    destinition.sequeExtraAiConnectionIdArg = sender as? String
                }
            }
        }
    }
}
