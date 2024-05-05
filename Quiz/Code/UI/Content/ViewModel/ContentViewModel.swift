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

class ContentViewModel: ObservableObject {
    @Published var isBackEnabled: Bool = true
    @Published var items: [ContentModel] = []
    @Published var isWarning: Bool = false
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // TODO: Initialize your data or fetch from somewhere
        loadData()
    }
    
    func onItemClicked(_ model: ContentModel) {
        // TODO: Handle item clicked
        print("Item clicked")
    }
    
    func onOpenFileClicked() {
        // TODO: Handle open file clicked
        print("Open file clicked")
    }
    
    func onContentFormatClicked() {
        // TODO: Handle content format clicked
        print("Content format clicked")
    }
    
    private func loadData() {
        // TODO: Mock impl. Replace prod impl
        isLoading = true
        isWarning = false
        items = []
        
        // Simulate a delay of 10 seconds
        Just(
            [
                ContentModel(id: "1", name: "Item 1", filePath: "", isChecked: false, contentMarker: ""),
                ContentModel(id: "2", name: "Item 2", filePath: "", isChecked: true, contentMarker: ""),
                ContentModel(id: "3", name: "Item 3", filePath: "", isChecked: false, contentMarker: "")
            ]
        )
            .delay(
                for: .seconds(5),
                scheduler: DispatchQueue.main
            )
            .sink(
                receiveValue: { newItems in
                    self.isLoading = false
                    self.isWarning = false
                    self.items = newItems
                }
            )
            .store(in: &cancellables)
    }
}
