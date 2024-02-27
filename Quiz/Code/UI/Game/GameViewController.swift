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
import GoogleMobileAds
import AppTrackingTransparency
import AudioToolbox.AudioServices
import MaterialComponents.MaterialDialogs

private let recordSegueNext = "segueGameToRecord"
private let endSegueNext = "segueGameToEnd"

class GameViewController: UIViewController, GADFullScreenContentDelegate, GADBannerViewDelegate, AdGameRewardedProtocol, AdGameBannerProtocol, GameViewProtocol {

    @IBOutlet weak var gameNavigationItem: GameNavigationItem!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var questLabel: UILabel!
    @IBOutlet weak var oneAnswerButton: AnswerButton!
    @IBOutlet weak var twoAnswerButton: AnswerButton!
    @IBOutlet weak var threeAnswerButton: AnswerButton!
    @IBOutlet weak var fourAnswerButton: AnswerButton!

    @IBOutlet var answerButtons: [AnswerButton]!

    @IBOutlet weak var bannerContainerView: UIView!
    @IBOutlet weak var adButton: UIButton!

    var sequeExtraArgs: GameSequeExtraArgs?

    var bannerView: GADBannerView?
    var rewardedAd: GADRewardedAd?
    var isTakedReward = false

    var gamePresenter: GamePresenterProtocol?
    private var featureManager: FeatureManager?

    private var isAnswerBlocked = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequeExtraArgs == nil || !(sequeExtraArgs!.isValid()) {
            setEmptyStub()
            return
        }

        initPresenter()

        requestIdfaAndLoadAd()
    }

    // MARK: - IBAction

    @IBAction func answerClick(_ sender: AnswerButton!) {
        guard let sender = sender else {
            return
        }

        blockAnswers(isBlocked: true)

        switch sender {
        case oneAnswerButton: gamePresenter?.answer(index: 0)
        case twoAnswerButton: gamePresenter?.answer(index: 1)
        case threeAnswerButton: gamePresenter?.answer(index: 2)
        case fourAnswerButton: gamePresenter?.answer(index: 3)
        default: break
        }
    }

    // MARK: - GADFullScreenContentDelegate

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        gamePresenter?.handleReward(isSuccess: false)
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if isTakedReward == false {
            gamePresenter?.handleReward(isSuccess: false)
        }
    }

    // MARK: - GADBannerViewDelegate

    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if isShowBannerAd() {
            showBannerAd(isShow: true)
            addBannerViewToView()

            bannerView.alpha = 0
            UIView.animate(withDuration: 1, animations: {
                bannerView.alpha = 1
            })
        } else {
            showBannerAd(isShow: false)
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        showBannerAd(isShow: false)
    }

    // MARK: - AdGameRewardedProtocol

    func showRewardedAdDialog() {
        if !isShowRewardedAd() {
            gamePresenter?.handleReward(isSuccess: false)
            return
        }

        let nextHandler: MDCActionHandler = { [weak self] (action) in
            self?.gamePresenter?.handleReward(isSuccess: false)
        }
        let rewardHandler: MDCActionHandler = { [weak self] (action) in
            self?.showRewardedAd()
        }

        let alertController = RewardAlertControllerBuilder.with()
                .addAgreeAction(handler: nextHandler)
                .addCancelAction(handler: rewardHandler).build()

        present(alertController, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }

    func showRewardedAd() {
        if isShowRewardedAd() {
            let handler = { [weak self] in
                self?.gamePresenter?.handleReward(isSuccess: true)
                self?.isTakedReward = true
            }
            rewardedAd?.present(
                    fromRootViewController: self,
                    userDidEarnRewardHandler: handler
            )
        } else {
            gamePresenter?.handleReward(isSuccess: false)
            return
        }
    }

    // MARK: - AdGameBannerProtocol

    func disableBannerAd() {
        bannerContainerView?.isHidden = true
    }

    func showBannerAd(isShow: Bool) {
        if isShow {
            adButton?.isHidden = true
            bannerView?.isHidden = false
        } else {
            adButton?.isHidden = false
            bannerView?.isHidden = true

            adButton.alpha = 0
            UIView.animate(withDuration: 1, animations: { [weak self] in
                self?.adButton.alpha = 1
            })
        }
    }

    // MARK: - BarGameView

    func setupConditionView(type: GameProcess.ConditionType) {
        switch type {
        case .life: gameNavigationItem.delgate = LifeGameNavigationItemDelegate()
        case .time: gameNavigationItem.delgate = TimeGameNavigationItemDelegate()
        }
        gameNavigationItem?.setupCondition()
    }

    func updatePoint(value: Int) {
        gameNavigationItem?.updatePoint(value: value)
    }

    func updateCondition(type: GameProcess.ConditionType, value: Int) {
        var condition = value
        if condition < 0 {
            condition = 0
        }
        gameNavigationItem?.updateCondition(value: condition)
    }

    func updateProgress(value: Int) {
        progressView.setProgressColor(progress: value)
        progressView.setProgress(value, animated: true)
    }

    // MARK: - ContentGameView

    func updateQuestContent(quest: String) {
        questLabel?.text = quest
    }

    func updateAnswerContent(answers: [String]) {
        oneAnswerButton?.setTitle(answers[0], for: .normal)
        twoAnswerButton?.setTitle(answers[1], for: .normal)
        threeAnswerButton?.setTitle(answers[2], for: .normal)
        fourAnswerButton?.setTitle(answers[3], for: .normal)
    }

    func setupViews() {
        scrollView.setContentOffset(.zero, animated: true)
    }

    // MARK: - AnswerControlGameView

    func highlightSelectedAnswer(index: Int, isTrueAnswer isHighlight: Bool) {
        if isHighlight {
            highlightAnswerTrueForm(index: index)
        } else {
            highlightAnswerFalseForm(index: index)
        }
    }

    func highlightAnswerTrueForm(index: Int) {
        getAnswerByIndex(index: index)?.highlight(state: .trueState)
    }

    func highlightAnswerFalseForm(index: Int) {
        getAnswerByIndex(index: index)?.highlight(state: .falseState)
    }

    func showTrueAnswer(index: Int) {
        highlightAnswerTrueForm(index: index)
    }

    func clearAnswerForms() {
        answerButtons?.forEach {
            $0.highlight(state: .clearState)
        }
    }

    func blockAnswers(isBlocked: Bool) {
        isAnswerBlocked = isBlocked
        answerButtons?.forEach {
            $0.isEnabled = !isBlocked
        }
    }

    func vibrate() {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
    }

    // MARK: - GameViewProtocol inner members

    func setEmptyStub() {
        view?.subviews.forEach {
            $0.removeFromSuperview()
        }
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    func finish(sequeExtraArgs: EndSequeExtraArgs?) {
        guard let sequeExtraArgs = sequeExtraArgs else {
            return self.dismiss(animated: true, completion: nil)
        }

        if sequeExtraArgs.gameMode != .error && sequeExtraArgs.point > sequeExtraArgs.oldRecord {
            performSegue(withIdentifier: recordSegueNext, sender: sequeExtraArgs)
        } else {
            performSegue(withIdentifier: endSegueNext, sender: sequeExtraArgs)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sequeData = sender as? EndSequeExtraArgs else {
            return
        }

        if let destinition = segue.destination as? UIViewController & EndViewProtocol {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            destinition.sequeExtraArgs = sequeData
        }
    }

    // MARK: - Public section

    @objc func dismissAlertController() {
        self.dismiss(animated: true) { [weak self] in
            self?.gamePresenter?.handleReward(isSuccess: false)
        }
    }

    // MARK: - Private section

    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        featureManager = IocContainer.app.resolve()

        gamePresenter = GamePresenter(contentRepository: contentRepository,
                userRepository: userRepository,
                mode: sequeExtraArgs!.gameMode!,
                themeId: sequeExtraArgs!.themeId!,
                sectionId: sequeExtraArgs!.sectionId,
                record: sequeExtraArgs!.record)
        gamePresenter?.attachRootView(rootView: self)
        gamePresenter?.setupBarViews()
        gamePresenter?.loadData()
    }

    private func getAnswerByIndex(index: Int) -> AnswerButton? {
        switch index {
        case 0: return oneAnswerButton
        case 1: return twoAnswerButton
        case 2: return threeAnswerButton
        case 3: return fourAnswerButton
        default: return nil
        }
    }

    private func requestIdfaAndLoadAd() {
        guard isAdEnabled() else {
            disableBannerAd()
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
        // Banner
        bannerView = GADBannerView(adSize: GADAdSizeLargeBanner)
        bannerView?.adUnitID = GlobalScope.content.kGameBannerAdUnitID
        bannerView?.rootViewController = self
        bannerView?.delegate = self
        bannerView?.load(GADRequest())

        // Rewarded
        GADRewardedAd.load(
                withAdUnitID: GlobalScope.content.kGameRewardedAdUnitID,
                request: GADRequest(),
                completionHandler: { [weak self] (ad, error) in
                    if let error = error {
                        print("Rewarded ad failed to load with error: \(error.localizedDescription)")
                        return
                    }
                    self?.rewardedAd = ad
                    self?.rewardedAd?.fullScreenContentDelegate = self
                }
        )
    }

    private func addBannerViewToView() {
        guard let container = bannerContainerView, let banner = bannerView else {
            return
        }

        banner.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(banner)
        container.addConstraints(
                [
                    NSLayoutConstraint(item: banner,
                            attribute: .bottom,
                            relatedBy: .equal,
                            toItem: container,
                            attribute: .bottom,
                            multiplier: 1,
                            constant: 0),
                    NSLayoutConstraint(item: banner,
                            attribute: .centerX,
                            relatedBy: .equal,
                            toItem: container,
                            attribute: .centerX,
                            multiplier: 1,
                            constant: 0)
                ]
        )
    }

    private func isAdEnabled() -> Bool {
        let mode: ContentMode = IocContainer.app.resolve()
        return featureManager?.isAdEnabled() == true && mode == .lite
    }

    private func isShowRewardedAd() -> Bool {
        return isAdEnabled() && rewardedAd != nil
    }

    private func isShowBannerAd() -> Bool {
        return isAdEnabled() && bannerView != nil
    }
}
