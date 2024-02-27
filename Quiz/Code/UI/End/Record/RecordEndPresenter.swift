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

class RecordEndPresenter: RecordEndPresenterProtocol {

    fileprivate weak var rootView: RecordEndViewProtocol?

    private var featureManager: FeatureManager
    private var remoteConfigRepository: RemoteConfigRepository
    private var mode: Mode

    private let titles = [
        NSLocalizedString("TITLE_WELL", comment: "Great!"),
        NSLocalizedString("TITLE_AMAZING", comment: "Amazing!")
    ]
    private let subtitles = [
        NSLocalizedString("MSG_NEW_RECORD", comment: "A new record has been set! Did you like it?")
    ]

    var isTelegramFeatureEnabled: Bool = false

    init(featureManager: FeatureManager,
         remoteConfigRepository: RemoteConfigRepository,
         mode: Mode
    ) {
        self.featureManager = featureManager
        self.remoteConfigRepository = remoteConfigRepository
        self.mode = mode
    }

    func attachRootView(rootView: RecordEndViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        isTelegramFeatureEnabled = featureManager.isTelegramEnabled()
        let config = remoteConfigRepository.fetchTelegramConfig()

        if isTelegramFeatureEnabled && config != nil {
            rootView?.updateContent(
                    title: config!.gameEnd.title,
                    subtitle: config!.gameEnd.message,
                    button: config!.gameEnd.buttonTitle.uppercased()
            )
        } else {
            let title = titles.randomElement()!
            let subtitle = subtitles.randomElement()!
            let buttonTitle = NSLocalizedString("ACTION_LEAVE_RATE", comment: "Leave a review").uppercased()

            rootView?.updateContent(
                    title: title,
                    subtitle: subtitle,
                    button: buttonTitle
            )
        }
    }

    func onActionClicked() {
        if isTelegramFeatureEnabled {
            rootView?.navigateToTelegram()
        } else {
            rootView?.navigateToRate()
        }
    }
}
