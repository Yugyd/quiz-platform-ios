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

private let reuseIdentifier = "SubscribeCell"

class SubscribeViewController: UITableViewController, SubscribeViewProtocol {

    weak var updateCallback: ProUpdateCallback?

    private var indicatorView: UIActivityIndicatorView!

    private var presenter: SubscribePresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        initPresenter()

        addIndicatorView()

        configurateNotificationCenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        presenter?.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        updateCallback?.update()
        super.viewWillDisappear(animated)
    }

    // MARK: - IBAction

    @IBAction func actionPrivacyPollicy(_ sender: Any) {
        Web.openLink(link: GlobalScope.content.privacyPollicy)
    }

    @IBAction func actionTermsAndConditions(_ sender: Any) {
        Web.openLink(link: StaticScope.termsLink)
    }

    @IBAction func actionRestorePurchase(_ sender: Any) {
        presenter?.restorePurchases()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.subscribes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SubscribeViewCell

        if let data = presenter?.subscribes[indexPath.row] {
            let price: String
            if (presenter?.canMakePayments() ?? false) {
                price = presenter?.priceFormatter.format(subscribe: data) ?? "\(data.price) ₽"
            } else {
                price = String(localized: "subscribe_not_available", table: appLocalizable)
            }

            cell.updateCell(title: data.title, price: price)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // open store - buy func
        if let subscribe = presenter?.subscribes[indexPath.row] {
            guard presenter?.canMakePayments() ?? false else {
                return
            }
            // ->
            _ = presenter?.buyProduct(productId: subscribe.id)
        }
    }

    // MARK: - Public func

    @objc func showRestoreAlert(_ notification: Notification) {
        if let isRestored = notification.userInfo?[IAPSwiftHelper.keyRestoreNotificationUserInfo] as? Bool {
            let alert: UIAlertController

            if isRestored {
                alert = AlertBuilder
                        .with()
                        .setTitle(String(localized: "RESTORE_ALERT_TITLE", table: appLocalizable))
                        .setMsg(String(localized: "RESTORE_ALERT_MSG", table: appLocalizable))
                        .setAction(title: String(localized: "RESTORE_ALERT_ACTION", table: appLocalizable))
                        .build()
            } else {
                alert = AlertBuilder.with()
                        .setTitle(String(localized: "RESTORE_ALERT_ERROR_TITLE", table: appLocalizable))
                        .setMsg(String(localized: "RESTORE_ALERT_ERROR_MSG", table: appLocalizable))
                        .setAction(title: String(localized: "RESTORE_ALERT_ACTION", table: appLocalizable))
                        .build()
            }
            if presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // MARK: - SubscribeViewProtocol

    func updateCollection() {
        tableView?.reloadData()
    }

    func visibleProgressView(_ isVisible: Bool) {
        indicatorView?.isHidden = !isVisible
    }

    func showProductErrorAlert(type: ErrorType) {
        let alert = AlertBuilder.with().setTitle(String(localized: "RESTORE_ALERT_ERROR_TITLE", table: appLocalizable))
                .setMsg(String(localized: "PRODUCTS_ALERT_ERROR_MSG", table: appLocalizable))
                .setAction(title: String(localized: "RESTORE_ALERT_ACTION", table: appLocalizable))
                .build()
        self.present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(type: ErrorType) {
        let alert: UIAlertController

        switch type {
        case .requestProducts:
            alert = AlertBuilder
                    .with()
                    .setTitle(String(localized: "RESTORE_ALERT_ERROR_TITLE", table: appLocalizable))
                    .setMsg(String(localized: "PRODUCTS_ALERT_ERROR_MSG", table: appLocalizable))
                    .setAction(title: String(localized: "RESTORE_ALERT_ACTION", table: appLocalizable))
                    .build()
        case .buyProduct:
            alert = AlertBuilder
                    .with()
                    .setTitle(String(localized: "RESTORE_ALERT_ERROR_TITLE", table: appLocalizable))
                    .setMsg(String(localized: "PRODUCT_BUY_ALERT_ERROR_MSG", table: appLocalizable))
                    .setAction(title: String(localized: "RESTORE_ALERT_ACTION", table: appLocalizable))
                    .build()
        }

        self.present(alert, animated: true, completion: nil)
    }

    func setEmptyStub() {

    }

    // MARK: - Private func

    private func initPresenter() {
        presenter = SubscribePresenter(iapHelper: IocContainer.app.resolve())
        presenter?.attachView(rootView: self)
        //presenter?.loadData()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.backgroundColor = UIColor.systemBackground
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

    private func configurateNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(showRestoreAlert(_:)), name: NSNotification.Name.IAPHelperRestoreNotification, object: nil)
    }
}
