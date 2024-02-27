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

class ValuePrefPresenter: ValuePrefPresenterProtocol {

    var prefMode: ValuePrefMode
    var data: [String] = [String]()

    fileprivate weak var rootView: ValuePrefViewProtocol?

    private let preferences: Preferences
    private let delegate: ValueItemDataDelegate

    init(prefMode: ValuePrefMode) {
        self.prefMode = prefMode
        self.preferences = UserPreferences()

        switch prefMode {
        case .notification:
            self.delegate = NotificationValueItemDataDelegate()
        case .transition:
            self.delegate = TransitionValueItemDataDelegate()
        }
    }

    func attachRootView(rootView: ValuePrefViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        data = delegate.loadData()

        rootView?.updateTable()
    }

    func loadCurrentValue() {
        let index = delegate.getCurrentIndexByPreferencesValue(preferences: preferences)

        rootView?.selectRow(index: index)
    }

    func changePref(index: Int) {
        delegate.setPreferencesValue(preferences: preferences, index: index)
    }
}
