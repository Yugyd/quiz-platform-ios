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

protocol ProfilePresenterProtocol: AnyObject {

    var sectionData: [SectionItem] { get }

    var itemData: Dictionary<SectionItem, [ProfileItem]> { get }

    var preferences: Preferences { get }

    func attachView(rootView: ProfileViewProtocol)

    func loadData()

    func restorePurchases()

    func getItemByIndexPath(index: IndexPath) -> ProfileItem

    func getContentValue(item: ProfileItem) -> (connectSubtitle: String, action: String)

    func getSwitchValue(item: ProfileItem) -> Bool

    func getDetailValue(item: ProfileItem) -> String
}
