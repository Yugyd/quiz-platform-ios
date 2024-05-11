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

class ContentClientImpl: ContentClient {
    
    private let loggerTag = "ContentClientImpl"
    
    private let logger: Logger
    
    private var stubSelectedContentModel: ContentModel? = ContentModel(
        id: "1",
        name: "Item 1",
        filePath: "item_1.txt",
        isChecked: true,
        contentMarker: "1"
    )
    
    init(logger: Logger) {
        self.logger = logger
    }
    
    func isSelected() async -> Bool {
        let isSelected = stubSelectedContentModel != nil
        logger.print(
            tag: loggerTag,
            message: "Is selected content: \(isSelected)"
        )
        return stubSelectedContentModel != nil
    }
    
    func getSelectedContent() async -> ContentModel? {
        let data = stubSelectedContentModel
        logger.print(
            tag: loggerTag,
            message: "Get selected content: \(String(describing: subscribeToSelectedContent))"
        )
        return data
    }
    
    func subscribeToContents() -> AnyPublisher<[ContentModel], Never> {
        return Just(
            [
                stubSelectedContentModel!,
                ContentModel(id: "2", name: "Item 2", filePath: "item_2.txt", isChecked: false, contentMarker: "2"),
                ContentModel(id: "3", name: "Item 3", filePath: "item_3.txt", isChecked: false, contentMarker: "3")
            ]
        )
        .handleEvents(
            receiveOutput: { [weak self] models in
                let tag = self?.loggerTag
                
                self?.logger.print(
                    tag: tag!,
                    message: "Subscribe to contents. New items: \(models)"
                )
            }
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    func subscribeToSelectedContent() -> AnyPublisher<ContentModel?, Never> {
        return Just(
            stubSelectedContentModel
        )
        .handleEvents(
            receiveOutput: { [weak self] model in
                self?.logContentModelEvent(model: model)
            }
        )
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    func setContent(newModel: ContentModel, oldModel: ContentModel) async throws -> Bool {
        logger.print(
            tag: loggerTag,
            message: "Set content started. New: \(newModel), old: \(oldModel)"
        )
        
        let filePath = newModel.filePath
        let contentMarker = newModel.contentMarker
        logger.print(
            tag: loggerTag,
            message: "Load data from \(filePath). Content marker: \(contentMarker)"
        )
        
        return true
    }
    
    func addContent(oldModel: ContentModel?, contentName: String?, filePath: String) async throws -> Bool {
        let oldModelMessage = String(describing: oldModel)
        logger.print(
            tag: loggerTag,
            message: "Set content started. Old: \(oldModelMessage), contentName: \(contentName ?? "nil"), filePath: \(filePath)"
        )
        
        logger.print(
            tag: loggerTag,
            message: "Load data from file path: \(filePath)"
        )
        
        return true
    }
    
    func deleteContent(id: String) async {
        logger.print(
            tag: loggerTag,
            message: "Delete content: \(id)"
        )
    }
    
    private func logContentModelEvent(model: ContentModel?) {
        let message: String
        if model != nil {
            message = String(describing: model)
        } else {
            message = "nil"
        }
        
        logger.print(
            tag: loggerTag,
            message: "Subscribe to selected content. New selected item: \(message)"
        )
    }
}
