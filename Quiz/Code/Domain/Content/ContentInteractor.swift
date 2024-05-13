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

protocol ContentInteractor {
    
    /**
     * Whether at least one content is selected or not.
     */
    func isSelected() async -> Bool
    
    /**
     * Quick access to selected content.
     */
    func getSelectedContent() async -> ContentModel?
    
    
    /**
     * Quick access to a list of all contents
     */
    func subscribeToContents() -> AnyPublisher<[ContentModel], Never>
    
    /**
     * Quick access to selected content.
     */
    func subscribeToSelectedContent() -> AnyPublisher<ContentModel?, Never>
    
    /**
     * Method whether to reset the internal navigation to the root screen. Needed for a case to reassemble data for new content. For example, exiting the progress details screen and
     * sections screen.
     */
    func isResetNavigation(oldModel: ContentModel?, newModel: ContentModel?) -> ContentResult
    
    /**
     * Removing content.
     */
    func deleteContent(id: String) async throws
    
    /**
     * Add new content.
     */
    func addContent(oldModel: ContentModel?, contentName: String?, uri: String) async throws -> Bool
    
    /**
     * Content selection.
     *
     * - Throws: ContentNotValidError.
     */
    func selectContent(oldModel: ContentModel, newModel: ContentModel) async throws -> Bool
    
    /**
     * Returns a reference to the content format.
     */
    func getContentFormatUrl() async throws -> String
    
    /**
     * Returns the file name from the URL, which will be used as the content name.
     */
    func getContentNameFromUri(uri: String) async throws -> String
}
