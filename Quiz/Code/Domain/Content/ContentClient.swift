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

protocol ContentClient {
    
    /**
     * A method that determines whether at least one content is selected or not. Useful to start selecting content when you first start.
     *
     * - Returns: Whether the content has been selected.
     */
    func isSelected() async throws-> Bool
    
    /**
     * The method provides quick access to selected content. Useful for quickly displaying selected content data. For example, a cell in a profile.
     */
    func getSelectedContent() async throws -> ContentModel?
    
    /**
     * The method provides a subscription for quick access to a list of all content. For example, the content screen.
     */
    func subscribeToContents() -> AnyPublisher<[ContentModel], Never>
    
    /**
     * Method provides a subscription for quick access to selected content. Useful for reacting reactively to changing content. For example, catalog screens, etc.
     */
    func subscribeToSelectedContent() -> AnyPublisher<ContentModel?, Never>
    
    /**
     * Content selection. For example, selecting content from a list.
     *
     * - Parameter newModel: Previously uploaded content.
     * - Parameter oldModel: Content to be replaced.
     * - Returns: True if new content is installed, false if the content is already current.
     * - Throws: ContentNotValidError, DuplicateIdQuestsError, DuplicateIdThemesError, NotValidQuestsError, NotValidThemesError
     */
    func setContent(newModel: ContentModel, oldModel: ContentModel) async throws -> Bool
    
    /**
     * Add new content from scratch. For example, selecting content on the empty state screen or if the user clicks on the add content button on the content screen.
     *
     * - Parameter oldModel: Content to be replaced.
     * - Parameter contentName: Name of the content.
     * - Parameter filePath: File path of the new content received from external storage.
     * - Returns: True if new content is installed, false if the content is already current.
     * - Throws: DuplicateIdQuestsError, DuplicateIdThemesError, NotValidQuestsError, NotValidThemesError
     */
    func addContent(oldModel: ContentModel?, contentName: String?, filePath: String) async throws  -> Bool
    
    /**
     * Removing content.
     */
    func deleteContent(id: String) async throws
}
