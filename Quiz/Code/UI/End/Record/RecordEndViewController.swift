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

private let segueNext = "segueRecordToEnd"

class RecordEndViewController: UIViewController, RecordEndViewProtocol {

    var sequeExtraArgs: EndSequeExtraArgs?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!

    fileprivate var presenter: RecordEndPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequeExtraArgs == nil || isErrorSequeExtraArgs() {
            setEmptyStub()
            return
        }

        initPresenter()
    }

    // MARK: - IBAction

    @IBAction func actionRate(_ sender: Any) {
        presenter?.onActionClicked()
    }

    @IBAction func actionNext(_ sender: Any) {
        startNext()
    }

    // MARK: - RecordEndViewProtocol

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
        startNext()
    }

    func updateContent(title: String, subtitle: String, button: String) {
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
        actionButton.setTitle(button, for: .normal)
    }

    func navigateToRate() {
        Web.openRateApp()
    }

    func navigateToTelegram() {
        Web.openTelegram(channelDomain: GlobalScope.content.telegramDomain)
    }

    // MARK: - Private section

    private func isErrorSequeExtraArgs() -> Bool {
        return !(sequeExtraArgs?.isValid() ?? true)
    }

    private func startNext() {
        performSegue(withIdentifier: segueNext, sender: sequeExtraArgs)
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

    // MARK: - Private func

    private func initPresenter() {
        let featureManager: FeatureManager = IocContainer.app.resolve()
        let remoteConfigRepository: RemoteConfigRepository = IocContainer.app.resolve()

        presenter = RecordEndPresenter(
                featureManager: featureManager,
                remoteConfigRepository: remoteConfigRepository,
                mode: sequeExtraArgs!.gameMode
        )
        presenter?.attachRootView(rootView: self)
        presenter?.loadData()
    }
}
