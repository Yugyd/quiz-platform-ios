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
import StoreKit

private let accountReuseIdentifier = "AccountCell"
private let textReuseIdentifier = "TextCell"
private let detailReuseIdentifier = "DetailCell"
private let switchReuseIdentifier = "SwitchCell"
private let twoTextReuseIdentifier = "TwoTextCell"
private let openSourceReuseIdentifier = "OpenSourceCell"

private let segueProfileToPro = "segueProfileToPro"
//private let segueProfileToSupportProject = "segueProfileToSupportProject"
private let segueProfileToValuePref = "segueProfileToValuePref"
private let segueProfileToReport = "segueProfileToReport"
private let segueProfileToContent = "segueProfileToContent"

class ProfileTableViewController: UITableViewController, ProfileViewProtocol {
   
    private var indicatorView: UIActivityIndicatorView!
    
    fileprivate var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPresenter()
        
        addIndicatorView()
        
        configurateNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.loadData()
        
        updateValuePrefSectionTable()
        
        visibleProgressView(false)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.sectionData.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else {
            return 0
        }
        return presenter.itemData[presenter.sectionData[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = presenter?.sectionData[section].title
        return if title?.isEmpty == true {
            nil
        } else {
            title
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter = presenter else {
            return UITableViewCell()
        }
        
        let item: ProfileItem = presenter.getItemByIndexPath(index: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: getReuseIdentifier(rowIdentifier: item.row.rowIdentifier), for: indexPath)
        cell.backgroundColor = .clear
        
        setupCell(cell: cell, item: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = presenter?.getItemByIndexPath(index: indexPath) else {
            return
        }
        action(item: item)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == segueProfileToValuePref {
            let profileItem: ProfileItem = sender as! ProfileItem
            let destinition = segue.destination as? UIViewController & ValuePrefViewProtocol
            
            if profileItem.identifier == .notification {
                destinition?.sequePrefModeExtraArg = .notification
                destinition?.navigationItem.title = "Настройка уведомлений"
            } else if profileItem.identifier == .transition {
                destinition?.sequePrefModeExtraArg = .transition
                destinition?.navigationItem.title = "Просмотр ответа"
            }
        } else if segue.identifier! == segueProfileToContent {
            let destinition = segue.destination as? UIViewController & ContentViewProtocol
            destinition?.isBackEnabled = true
        }
    }
    
    // MARK: - Public func
    
    @objc func switchAction(sender: UISwitch!) {
        if sender.tag == SwitchProfileRow.sortingTag {
            presenter?.preferences.isSorting = sender.isOn
        } else if sender.tag == SwitchProfileRow.vibrationTag {
            presenter?.preferences.isVibration = sender.isOn
        }
    }
    
    @objc func updateUi() {
        presenter?.loadData()
    }
    
    @objc func showRestoreAlert(_ notification: Notification) {
        if let isRestored = notification.userInfo?[IAPSwiftHelper.keyRestoreNotificationUserInfo] as? Bool {
            let alert: UIAlertController
            
            let actionTitle = NSLocalizedString("RESTORE_ALERT_ACTION", comment: "OK")
            if isRestored {
                alert = AlertBuilder
                    .with()
                    .setTitle(NSLocalizedString("RESTORE_ALERT_TITLE", comment: "Successfully"))
                    .setMsg(NSLocalizedString("RESTORE_ALERT_MSG", comment: "Purchases have been restored."))
                    .setAction(title: actionTitle)
                    .build()
            } else {
                alert = AlertBuilder
                    .with()
                    .setTitle(NSLocalizedString("RESTORE_ALERT_ERROR_TITLE", comment: "Error"))
                    .setMsg(NSLocalizedString("RESTORE_ALERT_ERROR_MSG", comment: "Purchases have not been restored. Try again."))
                    .setAction(title: actionTitle)
                    .build()
            }
            if presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - ProfileViewProtocol
    
    func updateTable() {
        tableView?.reloadData()
    }
    
    func updateTableHeader(contentMode: ContentMode) {
        if let header = tableView?.tableHeaderView as? AppHeaderView {
            let color: UIColor
            switch contentMode {
            case .lite:
                color = UIColor.secondaryLabel
            case .pro:
                color = UIColor(named: "color_accent") ?? UIColor.secondaryLabel
            }
            
            header.updateData(subscribeTitle: contentMode.titleName, color: color)
        }
    }
    
    func updateContent(content: String) {
        if let sectionIndex = presenter?.sectionData.firstIndex(where: { $0 == .top }) {
            let items = (presenter?.itemData[.top])!
            let selectContent: Int = items.firstIndex(where: { $0.identifier == .selectContent })!
            let index: IndexPath = IndexPath(row: selectContent, section: sectionIndex)
            
            if let cell = tableView?.cellForRow(at: index) {
                cell.detailTextLabel?.text = content
            }
        }
    }
    
    
    func updateSectionTable(index: Int) {
        tableView?.reloadSections(IndexSet.init(arrayLiteral: index), with: .none)
    }
    
    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }
    
    func visibleProgressView(_ isVisible: Bool) {
        indicatorView?.isHidden = !isVisible
    }
    
    // MARK: - Private func
    
    private func initPresenter() {
        presenter = ProfilePresenter(
            iapHelper: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        presenter?.attachView(rootView: self)
    }
    
    private func configurateNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUi), name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoreAlert(_:)), name: NSNotification.Name.IAPHelperRestoreNotification, object: nil)
    }
    
    // MARK: - Setup table cell
    
    private func getReuseIdentifier(rowIdentifier: ProfileRowIdentifier) -> String {
        let reuseIdentifier: String
        
        switch rowIdentifier {
        case .content:
            reuseIdentifier = accountReuseIdentifier
        case .text:
            reuseIdentifier = textReuseIdentifier
        case .value:
            reuseIdentifier = detailReuseIdentifier
        case .switched:
            reuseIdentifier = switchReuseIdentifier
        case .two_text:
            reuseIdentifier = twoTextReuseIdentifier
        case .opensource:
            reuseIdentifier = openSourceReuseIdentifier
        }
        
        return reuseIdentifier
    }
    
    private func setupCell(cell: UITableViewCell, item: ProfileItem) {
        switch item.row.rowIdentifier {
        case .content:
            let typeCell = cell as! ContentViewCell
            let typeRow = item.row as! ContentProfileRow
            typeCell.updateData(title: typeRow.title, subtitle: typeRow.subtitle, button: typeRow.buttonTitle)
        case .switched:
            let typeCell = cell as! SwitchViewCell
            let typeRow = item.row as! SwitchProfileRow
            let data = presenter?.getSwitchValue(item: item)
            typeCell.updateData(title: item.row.title, isOn: data, tag: typeRow.tag)
            typeCell.prefSwitch?.addTarget(self,
                                           action: #selector(switchAction(sender:)),
                                           for: .valueChanged)
        case .value:
            cell.textLabel?.text = item.row.title
            if let data = presenter?.getDetailValue(item: item) {
                cell.detailTextLabel?.text = data
            }
        case .text:
            cell.textLabel?.text = item.row.title
        case .two_text:
            let typeCell = cell as! TwoTextViewCell
            let typeRow = item.row as! TwoTextProfileRow
            typeCell.updateData(title: typeRow.title, subtitle: typeRow.subtitle)
        case .opensource:
            let typeCell = cell as! OpenSourceViewCell
            typeCell.updateData(
                onRatePlatformClicked: {
                    Web.openLink(link: StaticScope.quizPlatformProject)
                },
                onReportBugPlatformClicked: {
                    Web.openLink(link: StaticScope.quizPlatformIssues)
                }
            )
        }
    }
    
    // MARK: - Select action
    
    private func action(item: ProfileItem) {
        switch item.identifier {
            // Account section
        case .signAccount: break
            
            // Social section
        case .telegram:
            Web.openTelegram(channelDomain: GlobalScope.content.telegramDomain)
            
            // Purchase section
        case .pro:
            performSegue(withIdentifier: segueProfileToPro, sender: nil)
        case .supportProject: break // Beta Stub
            // performSegue(withIdentifier: segueProfileToSupportProject, sender: nil)
        case .restorePurchase:
            presenter?.restorePurchases()
            
            // Link section
        case .rateApp:
            Web.openRateApp()
        case .shareFriend:
            shareFriend()
        case .otherApps:
            Web.openLink(link: StaticScope.devLink)
            
            // Settings section
        case .notification:
            performSegue(withIdentifier: segueProfileToValuePref, sender: item)
            // update prefs -> in returns
        case .transition:
            performSegue(withIdentifier: segueProfileToValuePref, sender: item)
            // update prefs -> in returns
        case .sortQuest: break // UI action
        case .vibration: break // UI action
            
            // Text size
        case .questTextSize: break // Stub Bete
        case .answerTextSize: break // Stub Beta
            
            // Feedback
        case .reportError:
            performSegue(withIdentifier: segueProfileToReport, sender: nil)
        case .privacyPollicy:
            Web.openLink(link: GlobalScope.content.privacyPollicy)
        case .selectContent:
            performSegue(withIdentifier: segueProfileToContent, sender: nil)
            
            // Open-Source
        case .openSource: break
        }
    }
    
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
    
    private func updateValuePrefSectionTable() {
        if let sectionIndex = presenter?.sectionData.firstIndex(where: { $0 == .settings }) {
            let items = (presenter?.itemData[.settings])!
            let transition: Int = items.firstIndex(where: { $0.identifier == .transition })!
            let indexs: [IndexPath] = [IndexPath(row: transition, section: sectionIndex)]
            
            tableView?.reloadRows(at: indexs, with: .none)
        }
    }
    
    private func addIndicatorView() {
        indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        indicatorView.color = UIColor(named: "color_accent") ?? UIColor.systemOrange
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.backgroundColor = UIColor.systemBackground
        
        view.addSubview(indicatorView)
        indicatorView.isHidden = true
        
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
}
