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

class ProgressEndPresenter: ProgressEndPresenterProtocol {

    var mode: Mode
    var isRewardedSuccess: Bool

    fileprivate weak var rootView: ProgressEndViewProtocol?

    private var data: ProgressEnd
    private var themeTitle: String?

    private var contentRepository: ThemeRepositoryProtocol
    private var userRepository: ErrorRepositoryProtocol
    private var progressEndDelegate: ProgressEndDelegate

    init(contentRepository: ThemeRepositoryProtocol, userRepository: ErrorRepositoryProtocol, data: ProgressEnd, isRewardedOpen: Bool) {
        self.contentRepository = contentRepository
        self.userRepository = userRepository

        self.mode = data.mode
        self.data = data

        if self.data.mode == .error {
            self.progressEndDelegate = ErrorProgressEndDelegate()
        } else {
            self.progressEndDelegate = DefaultProgressEndDelegate()
        }

        self.isRewardedSuccess = isRewardedOpen
    }

    func attachRootView(rootView: ProgressEndViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            guard let themeId = self?.data.themeId else {
                self?.rootView?.setEmptyStub()
                return
            }

            if let data = self?.contentRepository.getThemeTitle(id: themeId) {
                DispatchQueue.main.async { [weak self] in
                    self?.themeTitle = data
                    self?.showData()
                }
            }
        }
    }

    private func showData() {
        if let themeTitle = themeTitle {
            let viewData = progressEndDelegate.buildViewData(mode: mode, themeTitle: themeTitle, point: data.point, count: data.count)
            rootView?.updateContent(themeTitle: viewData.title, progressSubtitle: viewData.subtitle, progressPercent: viewData.progressPercent)
        } else {
            rootView?.setEmptyStub()
        }
    }
}
