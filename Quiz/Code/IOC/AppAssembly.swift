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

class AppAssembly: GeneralAssembly {
    
    // TODO: Implement synchronized access to avoid creating multiple instances from different threads
    var userRepository: UserRepository! = nil
    var userDatabase: UserDatabaseProtocol! = nil
    var contentRepository: ContentRepository! = nil
    var contentMode: ContentMode! = nil
    var decoder: DecoderProtocol! = nil
    var iapHelper: IAPHelperProtocol! = nil
    var logger: Logger! = nil
    var aiConnectionLocalSource: AiConnectionLocalSource! = nil
    var aiRemoteConfigSource: AiRemoteConfigSource! = nil
    var aiQuestRemoteSource: AiQuestRemoteSource! = nil
    var courseInMemorySource: CourseInMemorySource! = nil
    var aiTasksInMemorySource: AiTasksInMemorySource! = nil
    var courseInteractor: CourseInteractor! = nil
    
    func enablePro() {
        contentRepository = nil
        contentMode = nil
    }
    
    // MARK: - Database (content)
    
    func resolve() -> UserRepository {
        if userRepository == nil {
            userRepository = UserRepository(userDb: resolve())
        }
        return userRepository
    }
    
    func resolve() -> UserDatabaseProtocol {
        if userDatabase == nil {
            userDatabase = UserDatabase(
                version: GlobalScope.content.userDbVersion,
                logger: resolve()
            )
        }
        
        return userDatabase
    }
    
    func resolve() -> ContentRepository {
        if contentRepository == nil {
            contentRepository = ContentRepository(contentDb: resolve())
        }
        return contentRepository
    }
    
    func resolve() -> ContentDatabaseProtocol {
        let questFormatter: SpecSymbolFormatter = resolve()
        return ContentDatabase(
            decoder: resolve(),
            questFormatter: questFormatter,
            version: GlobalScope.content.contentDbVersion,
            logger: resolve()
        )
    }
    
    // MARK: - Data utils
    
    func resolve() -> DecoderProtocol {
        if decoder == nil {
            decoder = DataDecoder()
        }
        return decoder
    }
    
    func resolve() -> SpecSymbolFormatter {
        return SpecSymbolFormatter()
    }
    
    func resolve() -> LineSeparatorFormatter {
        return LineSeparatorFormatter()
    }
    
    func resolve() -> TimeCalculator {
        return TimeCalculator()
    }
    
    func resolve() -> DefaultAbQuestParser {
        return DefaultAbQuestParser()
    }
    
    // MARK: - Domain
    
    func resolve() -> ContentMode {
        if contentMode == nil {
            let iapHelper: IAPHelperProtocol = resolve()
            let subscriptionDate = iapHelper.expirationDateFor() ?? Date() // Use Timestamp!
            
            if subscriptionDate > Date() {
                contentMode = .pro
            } else {
                contentMode = .pro
            }
        }
        
        return contentMode
    }
    
    func resolve() -> ContentRemoteConfigSource {
        return ContentRemoteConfigSourceImpl(
            remoteConfig: resolve()
        )
    }
    
    func resolve() -> TextToContentModelMapper {
        return TextToContentModelMapperImpl()
    }
    
    func resolve() -> ContentClient {
        let contentRepository: ContentRepository = resolve()
        let userDatabase: UserDatabaseProtocol = resolve()
        return ContentClientImpl(
            fileRepository: resolve(),
            textToContentEntityMapper: resolve(),
            themeRepository: contentRepository,
            questRepository: contentRepository,
            userRepository: resolve(),
            contentRepostiry: userDatabase,
            contentResetRepostiry: contentRepository,
            contentValidatorHelper: resolve(),
            logger: resolve()
        )
    }
    
    func resolve() -> ContentInteractor {
        return ContentInteractorImpl(
            contentClient: resolve(),
            fileRepository: resolve(),
            contentRemoteConfigSource: resolve()
        )
    }
    
    func resolve() -> UserPreferences {
        return UserPreferences()
    }
    
    func resolve() -> GamePreferences {
        let userPreferences: UserPreferences = resolve()
        return GamePreferences(
            preferences: userPreferences
        )
    }
    
    func resolve() -> TransitionInteractor {
        let pref: UserPreferences = resolve()
        return TransitionInteractor(
            preferences: pref
        )
    }
    
    func resolve() -> ProfileInteractor {
        return ProfileInteractorImpl()
    }
    
    // MARK: - In App
    
    func resolve() -> IAPHelperProtocol {
        if iapHelper == nil {
            let decoder: DecoderProtocol = resolve()
            iapHelper = IAPSwiftHelper(
                keyDataSource: resolve(),
                subscribeFactory: resolve(),
                decoder: decoder,
                dateFormatterFactory: resolve(),
                subscribeJsonMapper: resolve()
            )
        }
        
        return iapHelper
    }
    
    func resolve() -> ProductKeyDataSourceProtocol {
        return ProductKeyDataSource()
    }
    
    func resolve() -> SubscribeFactory {
        return SubscribeFactory()
    }
    
    func resolve() -> DateFormatterFactory {
        return DateFormatterFactory()
    }
    
    func resolve() -> SubscribeJsonMapper {
        return SubscribeJsonMapper(jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder())
    }
    
    // Mark: - FeatureToggle
    func resolve() -> FeatureManager {
        return FeatureManagerIml()
    }
    
    func resolve() -> RemoteConfigRepository {
        return RemoteConfigRepositoryImpl()
    }
    
    // Mark: Core
    func resolve() -> Logger {
        if logger == nil {
            logger = LoggerImpl()
        }
        return logger
    }
    
    func resolve() -> FileRepository {
        return FileRepositoryImpl()
    }
    
    // Mark: Services
    func resolve() -> AppRemoteConfig {
        return AppRemoteConfigImpl(logger: resolve())
    }
    
    // Mark: - Content
    
    func resolve() -> ContentValidatorHelper {
        return ContentValidatorHelperImpl()
    }
    
    // MARK:- AI
    
    func resolve() -> AiConnectionLocalSource {
        if aiConnectionLocalSource == nil {
            aiConnectionLocalSource = AiConnectionLocalDataSource()
        }
        return aiConnectionLocalSource
    }
    
    func resolve() -> AiConnectionClient {
        return AiConnectionClientImpl(
            aiConnectionLocalSource: resolve(),
            logger: resolve()
        )
    }
    
    func resolve() -> AiRemoteConfigSource {
        return AiRemoteConfigDataSource(
            remoteConfig: resolve(),
            aiInstructionConfigMapper: AiInstructionConfigMapper(),
            logger: resolve(),
            jsonDecoder: JSONDecoder()
        )
    }
    
    // MARK: - Network
    
    func resolve() -> NetworkFactory {
        return NetworkFactory()
    }
    
    // MARK: - AI
    
    func resolve() -> QuizPlatformApi {
        return QuizPlatformApiImpl(
            networkManager: resolve()
        )
    }
    
    func resolve() -> AiQuestRemoteSource {
        if aiQuestRemoteSource == nil {
            aiQuestRemoteSource = AiQuestRemoteDataSource(
                api: resolve(),
                mapper: AiQuestMapperImpl()
            )
        }
        return aiQuestRemoteSource
    }

    func resolve() -> AiQuestInteractor {
        return AiQuestInteractorImpl(remoteSource: resolve())
    }
    
    func resolve() -> AiTasksInMemorySource {
        if aiTasksInMemorySource == nil {
            aiTasksInMemorySource = AiTasksInMemoryDataSource()
        }
        
        return aiTasksInMemorySource
    }
    
    func resolve() -> AiTasksInteractor {
        return AiTasksInteractorImpl(
            aiQuestInteractor: resolve(),
            aiTasksInMemorySource: resolve())
        
    }
    
    // MARK: - Courses
    
    func resolve() -> CourseInMemorySource {
        if courseInMemorySource == nil {
            courseInMemorySource = CourseInMemoryDataSource()
        }
        
        return courseInMemorySource
    }
    
    func resolve() -> CourseInteractor {
        if courseInteractor == nil {
            courseInteractor = CourseInteractorImpl(
                aiQuestInteractor: resolve(),
                courseInMemorySource: resolve()
                
            )
        }
        
        return courseInteractor
    }
}
