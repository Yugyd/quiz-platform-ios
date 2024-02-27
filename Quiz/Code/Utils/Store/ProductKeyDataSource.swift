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

class ProductKeyDataSource: ProductKeyDataSourceProtocol {

    private var data: Set<String> = []

    func getData() -> Set<String> {
        if !(data.isEmpty) {
            return data
        }

        guard let url = Bundle.main.url(forResource: "Product", withExtension: "plist") else {
            fatalError("Unable to resolve url for in the bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let productIdentifiers = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String]
            self.data = Set(productIdentifiers ?? [])
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            self.data = []
        }

        return data
    }
}
