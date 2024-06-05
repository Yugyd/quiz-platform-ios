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

import Combine
import UIKit

class CorrectViewController: UIViewController, CorrectViewProtocol {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    fileprivate var presenter: CorrectPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initPresenter()
        
        configuratePurchaseNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.loadData()
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
    
    // MARK: - CorrectViewProtocol
    
    func enableStartButton(isEnable: Bool) {
        startButton?.isEnabled = isEnable
    }
    
    func hideInfoLabel(isHide: Bool) {
        infoLabel?.isHidden = isHide
        startButton?.isHidden = !isHide
    }
    
    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }
    
    // MARK: - Public func
    
    @objc func updateUi() {
        presenter?.loadData()
    }
    
    // MARK: - Private func
    
    private func initPresenter() {
        let userRepository: UserRepository = IocContainer.app.resolve()
        presenter = CorrectPresenter(
            repository: userRepository,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        presenter?.attachView(rootView: self)
    }
    
    private func configuratePurchaseNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUi), name: NSNotification.Name.IAPHelperPurchaseNotification, object: nil)
    }
}
