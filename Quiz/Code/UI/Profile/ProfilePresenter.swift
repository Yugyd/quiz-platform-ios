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
import Combine

@MainActor class ProfilePresenter: ProfilePresenterProtocol {
    
    var preferences: Preferences
    
    var sectionData: [SectionItem] {
        get {
            viewDataSource.sections
        }
    }
    
    var itemData: Dictionary<SectionItem, [ProfileItem]> {
        get {
            viewDataSource.getData()
        }
    }
    
    fileprivate weak var rootView: ProfileViewProtocol?
    private let iapHelper: IAPHelperProtocol
    private let viewDataSource: ProfileDataSourceProtocol
    //private let accountManager: AccountManagerProtocol
    private let contentInteractor: ContentInteractor
    private let logger: Logger
    
    private var cancellables = Set<AnyCancellable>()
    
    private let profileContentNotSelected = String(
        localized: "profile_title_content_not_selected",
        table: appLocalizable
    )
    
    init(
        iapHelper: IAPHelperProtocol,
        contentInteractor: ContentInteractor,
        logger: Logger
    ) {
        self.iapHelper = iapHelper
        self.preferences = UserPreferences()
        self.viewDataSource = BetaProfileDataSource()
        //self.accountManager = AccountManager()
        self.contentInteractor = contentInteractor
        self.logger = logger
    }
    
    func attachView(rootView: ProfileViewProtocol) {
        self.rootView = rootView
    }
    
    func loadData() {
        getContentMode()
        subscribeToSelectedContent()
    }
    
    func restorePurchases() {
        self.rootView?.visibleProgressView(true)
        iapHelper.restorePurchases { (isSuccess) in
            self.rootView?.visibleProgressView(false)
        }
    }
    
    func getItemByIndexPath(index: IndexPath) -> ProfileItem {
        let key = sectionData[index.section]
        let itemsInSection = itemData[key]!
        return itemsInSection[index.row]
    }
    
    func getContentValue(item: ProfileItem) -> (connectSubtitle: String, action: String) {
        fatalError("Stub - non supported method")
    }
    
    func getSwitchValue(item: ProfileItem) -> Bool {
        switch item.identifier {
        case .sortQuest:
            return preferences.isSorting
        case .vibration:
            return preferences.isVibration
        default:
            fatalError("getSwitchValue - Profile item no reg")
        }
    }
    
    func getDetailValue(item: ProfileItem) -> String {
        switch item.identifier {
        case .notification:
            return "Stub"
        case .transition:
            let value = preferences.transition
            let prefItem = TransitionPreference.instance(value: value)
            return prefItem?.title ?? ""
        case .questTextSize:
            return "Stub"
        case .answerTextSize:
            return "Stub"
        case .selectContent:
            return profileContentNotSelected
        default:
            fatalError("getDetailValue - Profile item no reg")
        }
    }
    
    private func getContentMode() {
        let contentMode: ContentMode = IocContainer.app.resolve()
        rootView?.updateTableHeader(contentMode: contentMode)
    }
    
    private func subscribeToSelectedContent() {
        contentInteractor
            .subscribeToSelectedContent()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.processContentError(error: error)
                    }
                },
                receiveValue: { [weak self] content in
                    self?.processContent(content: content)
                }
            )
            .store(in: &cancellables)
    }
    
    private func processContentError(error: Error) {
        logger.recordError(error: error)
    }
    
    private func processContent(content: ContentModel?) {
        let contentTitle = getContentTitle(content: content)
        rootView?.updateContent(content: contentTitle)
    }
    
    private func getContentTitle(content: ContentModel?) -> String {
        if content?.name != nil {
            return content!.name
        } else {
            return profileContentNotSelected
        }
    }
}
