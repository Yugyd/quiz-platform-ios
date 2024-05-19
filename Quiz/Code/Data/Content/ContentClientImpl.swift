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
    
    private static let FILE_SEPARATOR = "-"
    private static let CATEGORY_SECTION = "[category]"
    private static let QUEST_SECTION = "[quest]"
    private static let ITEM_SPLITTER = "\n\n"
    
    private let loggerTag = "ContentClientImpl"
    
    private let fileRepository: FileRepository
    private let textToContentEntityMapper: TextToContentModelMapper
    private let themeRepository: ThemeRepositoryProtocol
    private let questRepository: QuestRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let contentRepostiry: ContentRepositoryProtocol
    private let contentResetRepostiry: ContentResetRepositoryProtocol
    private let contentValidatorHelper: ContentValidatorHelper
    private let logger: Logger
    
    init(
        fileRepository: FileRepository,
        textToContentEntityMapper: TextToContentModelMapper,
        themeRepository: ThemeRepositoryProtocol,
        questRepository: QuestRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        contentRepostiry: ContentRepositoryProtocol,
        contentResetRepostiry: ContentResetRepositoryProtocol,
        contentValidatorHelper: ContentValidatorHelper,
        logger: Logger
    ) {
        self.fileRepository = fileRepository
        self.textToContentEntityMapper = textToContentEntityMapper
        self.themeRepository = themeRepository
        self.questRepository = questRepository
        self.userRepository = userRepository
        self.contentRepostiry = contentRepostiry
        self.contentResetRepostiry = contentResetRepostiry
        self.contentValidatorHelper = contentValidatorHelper
        self.logger = logger
    }
    
    func isSelected() async -> Bool {
        let isSelected = contentRepostiry.getSelectedContent() != nil
        
        logger.print(
            tag: loggerTag,
            message: "Is selected content: \(isSelected)"
        )
        
        return isSelected
    }
    
    func getSelectedContent() async -> ContentModel? {
        let data = contentRepostiry.getSelectedContent()
        
        logger.print(
            tag: loggerTag,
            message: "Get selected content: \(String(describing: data))"
        )
        
        return data
    }
    
    func subscribeToSelectedContent() -> AnyPublisher<ContentModel?, Never> {
        return contentRepostiry
            .subscribeToSelectedContentPublisher()
            .handleEvents(
                receiveOutput: { [weak self] model in
                    self?.logContentModelEvent(model: model)
                }
            )
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func subscribeToContents() -> AnyPublisher<[ContentModel], Never> {
        return contentRepostiry
            .subscribeToContentsPublisher()
            .handleEvents(
                receiveOutput: { [weak self] models in
                    if let self = self {
                        self.logger.print(
                            tag: loggerTag,
                            message: "Subscribe to contents. New items: \(String(describing: models))"
                        )
                    }
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
        
        // Read content file from external storage
        let filePath = newModel.filePath
        let rawText = try fileRepository.readTextFromFile(fileName: newModel.filePath)
        
        // Generate content tag
        let contentMarker = String(rawText.hashValue)
        
        logger.print(
            tag: loggerTag,
            message: "Load data from \(filePath). Content marker: \(contentMarker)"
        )
        
        // Check that this is not current content
        guard isNewSelected(contentMarker: contentMarker) else {
            return false
        }
        
        do {
            // Process content
            try processContent(rawText: rawText, contentMarker: contentMarker)
            
            let checkedNewModel = ContentModel(
                id: newModel.id,
                name: newModel.name,
                filePath: newModel.filePath,
                isChecked: true,
                contentMarker: newModel.contentMarker
            )
            let uncheckedOldModel = ContentModel(
                id: oldModel.id,
                name: oldModel.name,
                filePath: oldModel.filePath,
                isChecked: false,
                contentMarker: oldModel.contentMarker
            )
            contentRepostiry.updateContent(contentModel: checkedNewModel)
            contentRepostiry.updateContent(contentModel: uncheckedOldModel)
            
            logger.print(
                tag: loggerTag,
                message: "Set content successful. New content: \(checkedNewModel)"
            )
        } catch {
            logger.recordError(
                tag: loggerTag,
                error: error
            )
            logger.print(
                tag: loggerTag,
                message: "Set content failed"
            )
            logger.print(
                tag: loggerTag,
                message: "Delete new content item"
            )
            
            contentRepostiry.deleteContent(id: newModel.id)
            
            throw ContentNotValidError(
                message: "Delete old content item is \(newModel)",
                cause: error
            )
        }
        
        return true
    }
    
    func addContent(
        oldModel: ContentModel?,
        contentName: String?,
        filePath: String
    ) async throws -> Bool {
        let oldModelMessage = String(describing: oldModel)
        logger.print(
            tag: loggerTag,
            message: "Set content started. Old: \(oldModelMessage), name: \(contentName ?? ""), uri: \(filePath)"
        )
        
        // Read content file from external storage
        let rawText = try fileRepository.readTextFromFile(fileName: filePath)
        
        // Generate content tag
        let contentMarker = String(rawText.hashValue)
        
        logger.print(
            tag: loggerTag,
            message: "Load data from uri: \(filePath). Content marker: \(contentMarker)"
        )
        
        // Check that this is not current content
        guard isNewSelected(contentMarker: contentMarker), isExists(contentMarker: contentMarker) else {
            return false
        }
        
        // Copy file
        let localStorageFile = try getFileName(contentMarker: contentMarker, uri: filePath)
        logger.print(
            tag: loggerTag,
            message: "Local content file name: \(localStorageFile)"
        )
        
        let internalFile = try fileRepository.saveTextToLocalStorage(
            fileName: localStorageFile,
            fileContents: rawText
        )
        logger.print(
            tag: loggerTag,
            message: "Internal file path: \(internalFile ?? "nil")"
        )
        
        // Process content
        try processContent(rawText: rawText, contentMarker: contentMarker)
        
        if let oldModel = oldModel {
            let uncheckedOldModel = ContentModel(
                id: oldModel.id,
                name: oldModel.name,
                filePath: oldModel.filePath,
                isChecked: false,
                contentMarker: oldModel.contentMarker
            )
            contentRepostiry.updateContent(contentModel: uncheckedOldModel)
        }
        
        let name = contentName ?? localStorageFile.components(separatedBy: ".").first!
        let checkedNewModel = ContentModel(
            id: "",
            name: name,
            filePath: internalFile ?? "",
            isChecked: true,
            contentMarker: contentMarker
        )
        contentRepostiry.addContent(contentModel: checkedNewModel)
        
        logger.print(
            tag: loggerTag,
            message: "Set content successful. New content: \(checkedNewModel)"
        )
        
        return true
    }
    
    func deleteContent(id: String) async {
        logger.print(
            tag: loggerTag,
            message: "Delete content: \(id)"
        )
        
        contentRepostiry.deleteContent(id: id)
    }
    
    // MARK: Private
    
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
    
    private func isNewSelected(contentMarker: String) -> Bool {
        guard let oldContentMarker = contentRepostiry.getSelectedContent()?.contentMarker else {
            return true
        }
        
        if oldContentMarker == contentMarker {
            logger.print(
                tag: loggerTag,
                message: "Content is already selected. Old: \(oldContentMarker), new: \(contentMarker)"
            )
            return false
        } else {
            return true
        }
    }
    
    private func processContent(rawText: String, contentMarker: String) throws {
        logger.print(
            tag: loggerTag,
            message: "Process content is started. Raw text length: \(rawText.count), marker: \(contentMarker)"
        )
        
        // Map the data into the model
        let rawData = getRawData(rawText: rawText)
        let contentData = textToContentEntityMapper.map(raw: rawData)
        
        logger.print(
            tag: loggerTag,
            message: "Raw data mapped. Quest: \(contentData.quests.count), category: \(contentData.themes.count)"
        )
        
        // Data validation, filtering of invalid data
        try contentValidatorHelper.validateContent(contentData: contentData)
        
        // Reset data to database content
        try contentResetRepostiry.reset()
        
        // Write models to database
        themeRepository.addThemes(themes: contentData.themes)
        questRepository.addQuests(quests: contentData.quests)
        
        // Reset progress
        let result = userRepository.reset()
        
        logger.print(
            tag: loggerTag,
            message: "Reset content and user progress. Add content to database. Reset result: \(result)"
        )
    }
    
    private func getRawData(rawText: String) -> RawContentDataModel {
        let rawCategoryBlock = getCategoryBlock(rawText: rawText)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let rawCategories = rawCategoryBlock.components(
            separatedBy: ContentClientImpl.ITEM_SPLITTER
        )
        
        let rawQuestBlock = getQuestBlock(rawText: rawText)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let rawQuests = rawQuestBlock.components(
            separatedBy: ContentClientImpl.ITEM_SPLITTER
        )
        
        return RawContentDataModel(
            rawCategories: rawCategories,
            rawQuests: rawQuests
        )
    }
    
    private func getCategoryBlock(rawText: String) -> String {
        return rawText
            .components(separatedBy: ContentClientImpl.CATEGORY_SECTION)[1]
            .components(separatedBy: ContentClientImpl.QUEST_SECTION)[0]
    }
    
    private func getQuestBlock(rawText: String) -> String {
        return rawText
            .components(separatedBy: ContentClientImpl.QUEST_SECTION)[1]
    }
    
    private func isExists(contentMarker: String) -> Bool {
        let contentMarkers = contentRepostiry.getContents().map { $0.contentMarker }
        
        if contentMarkers.contains(contentMarker) {
            logger.print(
                tag: loggerTag,
                message: "Content is already selected. Olds: \(contentMarkers), new: \(contentMarker)"
            )
            return false
        } else {
            return true
        }
    }
    
    private func getFileName(contentMarker: String, uri: String) throws -> String {
        let uriFileName = try fileRepository.getFileName(uri: uri)
        return contentMarker + ContentClientImpl.FILE_SEPARATOR + uriFileName
    }
}
