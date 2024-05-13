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

class ContentInteractorImpl: ContentInteractor {
    
    private let fileTypePartPoint: Character = "."
    
    private let contentClient: ContentClient
    private let fileRepository: FileRepository
    private let contentRemoteConfigSource: ContentRemoteConfigSource
    
    init(
        contentClient: ContentClient,
        fileRepository: FileRepository,
        contentRemoteConfigSource: ContentRemoteConfigSource
    ) {
        self.contentClient = contentClient
        self.fileRepository = fileRepository
        self.contentRemoteConfigSource = contentRemoteConfigSource
    }
    
    func isSelected() async -> Bool {
        await contentClient.isSelected()
    }
    
    func getSelectedContent() async -> ContentModel? {
        await contentClient.getSelectedContent()
    }
    
    func subscribeToContents() -> AnyPublisher<[ContentModel], Never> {
        return contentClient
            .subscribeToContents()
            .receive(
                on: DispatchQueue.global(qos: .background)
            )
            .eraseToAnyPublisher()
    }
    
    func subscribeToSelectedContent() -> AnyPublisher<ContentModel?, Never> {
        return contentClient
            .subscribeToSelectedContent()
            .receive(
                on: DispatchQueue.global(qos: .background)
            )
            .eraseToAnyPublisher()
    }
    
    func isResetNavigation(oldModel: ContentModel?, newModel: ContentModel?) -> ContentResult {
        return ContentResult(
            isBack: oldModel != nil && oldModel != newModel,
            newModel: newModel
        )
    }
    
    func deleteContent(id: String) async {
        await contentClient.deleteContent(id: id)
    }
    
    func selectContent(oldModel: ContentModel, newModel: ContentModel) async throws -> Bool {
        let isAdded = try await contentClient.setContent(newModel: newModel, oldModel: oldModel)
        return isAdded
    }
    
    func addContent(oldModel: ContentModel?, contentName: String?, uri: String) async throws -> Bool {
        let isAdded = try await contentClient.addContent(oldModel: oldModel, contentName: contentName, filePath: uri)
        return isAdded
    }
    
    func getContentFormatUrl() async -> String {
        return await contentRemoteConfigSource.getContentFormatUrl()
    }
    
    func getContentNameFromUri(uri: String) async throws -> String {
        let fileName = try fileRepository.getFileName(uri: uri)
        let contentName = fileName.substringBeforeLast(fileTypePartPoint)
        let capitalizedContentName = contentName.prefix(1).capitalized + contentName.dropFirst()
        return capitalizedContentName
    }
}

extension String {
    func substringBeforeLast(_ separator: Character) -> String {
        guard let lastIndex = self.lastIndex(of: separator) else {
            return self
        }
        return String(self[..<lastIndex])
    }
}
