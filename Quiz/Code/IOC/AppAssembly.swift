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

    var userRepository: UserRepository! = nil
    var contentRepository: ContentRepository! = nil
    var contentMode: ContentMode! = nil
    var decoder: DecoderProtocol! = nil
    var iapHelper: IAPHelperProtocol! = nil

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
        return UserDatabase(version: GlobalScope.content.userDbVersion)
    }

    func resolve() -> ContentRepository {
        if contentRepository == nil {
            contentRepository = ContentRepository(contentDb: resolve())
        }
        return contentRepository
    }

    func resolve() -> ContentDatabaseProtocol {
        let questFormatter: SpecSymbolFormatter = resolve()
        return ContentDatabase(decoder: resolve(),
                questFormatter: questFormatter,
                mode: resolve())
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

    // MARK: - Domain

    func resolve() -> ContentMode {
        if contentMode == nil {
            let iapHelper: IAPHelperProtocol = resolve()
            let subscriptionDate = iapHelper.expirationDateFor() ?? Date() // Use Timestamp!

            if subscriptionDate > Date() {
                contentMode = .pro
            } else {
                contentMode = .lite
            }
        }

        return contentMode
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
}
