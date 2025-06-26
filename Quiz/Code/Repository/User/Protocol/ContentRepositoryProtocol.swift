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

protocol ContentRepositoryProtocol: AnyObject {
    
    func getContents() async throws -> [ContentModel]
    
    func subscribeToContentsPublisher() -> AnyPublisher<[ContentModel], Never>
    
    func getSelectedContent() async throws -> ContentModel?
    
    func subscribeToSelectedContentPublisher() -> AnyPublisher<ContentModel?, Never>
    
    func deleteContent(id: String) async throws
    
    func addContent(contentModel: ContentModel) async throws
    
    func updateContent(contentModel: ContentModel) async throws
}
