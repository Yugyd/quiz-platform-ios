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

class CorrectPresenter: CorrectPresenterProtocol {

    var isHaveErrors: Bool = false

    fileprivate weak var rootView: CorrectViewProtocol?

    private var repository: ErrorRepositoryProtocol

    init(repository: ErrorRepositoryProtocol) {
        self.repository = repository
    }

    func attachView(rootView: CorrectViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            let data = self?.repository.isHaveErrors()

            DispatchQueue.main.async { [weak self] in
                self?.handleData(data: data)
            }
        }
    }

    // MARK: - Private func

    private func handleData(data: Bool?) {
        guard let data = data else {
            rootView?.setEmptyStub()
            return
        }

        isHaveErrors = data

        let contentMode: ContentMode = IocContainer.app.resolve()
        if contentMode == .pro {
            rootView?.enableStartButton(isEnable: isHaveErrors)
            rootView?.hideInfoLabel(isHide: true)
        } else {
            rootView?.enableStartButton(isEnable: false)
            rootView?.hideInfoLabel(isHide: false)
        }
    }
}
