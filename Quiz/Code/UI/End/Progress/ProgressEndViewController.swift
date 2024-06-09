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
import AppTrackingTransparency
import GoogleMobileAds

private let segueNext = "segueEndToError"
private let unwindToTheme = "unwindToThemeViewController"
private let unwindToCorrect = "unwindToCorrectViewController"
private let unwindToSection = "unwindToSectionViewController"

class ProgressEndViewController: UIViewController, GADFullScreenContentDelegate, ProgressEndViewProtocol {

    var sequeExtraArgs: EndSequeExtraArgs?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressSubtitleLabel: UILabel!
    @IBOutlet weak var showErrorButton: UIButton!

    var interstitial: GADInterstitialAd?

    fileprivate var presenter: ProgressEndPresenter?
    private var featureManager: FeatureManager?

    private var isFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequeExtraArgs == nil || isErrorSequeExtraArgs() {
            setEmptyStub()
            return
        }

        let isShowErrorButtonEnabled = !(sequeExtraArgs!.errorQuestIds?.isEmpty ?? true)
        setupShowErrorButton(isEnabled: isShowErrorButtonEnabled)

        initPresenter()

        requestIdfaAndLoadAd()
    }

    // MARK: - IBAction

    @IBAction func newGameAction(_ sender: Any) {
        if isShowAd() {
            interstitial?.present(fromRootViewController: self)
        } else {
            startNewGame()
        }
    }

    @IBAction func showErrorAction(_ sender: Any) {
        performSegue(withIdentifier: segueNext, sender: sequeExtraArgs!.errorQuestIds)
    }

    // MARK: - GADInterstitialDelegate

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitial = nil
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitial = nil
        startNewGame()
    }

    // MARK: - ProgressEndViewProtocol

    func updateContent(themeTitle: String, progressSubtitle: String, progressPercent: Int) {
        titleLabel?.text = themeTitle
        progressSubtitleLabel?.text = progressSubtitle

        progressView?.setProgressColor(progress: progressPercent)
        progressView?.setProgress(progressPercent, animated: true)
    }

    func startNewGame() {
        guard !isFinish else {
            return
        }

        isFinish = true

        switch presenter?.mode {
        case .arcade:
            performSegue(withIdentifier: unwindToSection, sender: nil)
        case .error:
            performSegue(withIdentifier: unwindToCorrect, sender: nil)
        case .marathon, .sprint:
            performSegue(withIdentifier: unwindToTheme, sender: nil)
        case .unused, nil: fatalError()
        }
    }

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
        startNewGame() // Next seque -> Return for Game
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == unwindToTheme
                   || segue.identifier! == unwindToCorrect
                   || segue.identifier! == unwindToSection {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        } else if segue.identifier! == segueNext {
            guard let sequeData = sender as? Set<Int>? else {
                return
            }

            if let destinition = (segue.destination as? UINavigationController)?.viewControllers[0] as? ErrorTableViewProtocol {
                destinition.sequeExtraErrorIdsArg = sequeData
            }
        }
    }

    // MARK: - Private section

    private func isErrorSequeExtraArgs() -> Bool {
        return !sequeExtraArgs!.isValid()
    }

    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        featureManager = IocContainer.app.resolve()

        let data = ProgressEnd(mode: sequeExtraArgs!.gameMode,
                themeId: sequeExtraArgs!.themeId,
                point: sequeExtraArgs!.point,
                count: sequeExtraArgs!.count,
                errorQuestIds: sequeExtraArgs!.errorQuestIds)
        let isRewardedOpen = sequeExtraArgs!.isRewardedSuccess

        presenter = ProgressEndPresenter(contentRepository: contentRepository,
                userRepository: userRepository,
                data: data,
                isRewardedOpen: isRewardedOpen)
        presenter?.attachRootView(rootView: self)
        presenter?.loadData()
    }

    private func requestIdfaAndLoadAd() {
        guard isAdEnabled() else {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in
                    DispatchQueue.main.async { [weak self] in
                    }
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
        let request = GADRequest()
        GADInterstitialAd.load(
                withAdUnitID: GlobalScope.content.kEndInterstitialAdUnitID,
                request: request,
                completionHandler: { [self] ad, error in
                    if let error = error {
                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                        return
                    }
                    interstitial = ad
                    interstitial?.fullScreenContentDelegate = self
                }
        )
    }

    private func setupShowErrorButton(isEnabled: Bool) {
        showErrorButton?.isEnabled = isEnabled
        showErrorButton?.isUserInteractionEnabled = isEnabled
    }

    private func isAdEnabled() -> Bool {
        let mode: ContentMode = IocContainer.app.resolve()
        return featureManager?.isAdEnabled() == true && mode != .pro
    }

    private func isShowAd() -> Bool {
        return isAdEnabled() && interstitial != nil && presenter?.isRewardedSuccess == false
    }
}
