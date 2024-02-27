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

protocol GeneralAssembly {

    func enablePro()

    // MARK: - Database (content)

    func resolve() -> UserRepository

    func resolve() -> UserDatabaseProtocol

    func resolve() -> ContentRepository

    func resolve() -> ContentDatabaseProtocol

    // MARK: - Data utils

    func resolve() -> DecoderProtocol

    func resolve() -> SpecSymbolFormatter

    func resolve() -> LineSeparatorFormatter

    // MARK: - Domain

    func resolve() -> ContentMode

    // MARK: - In App

    func resolve() -> IAPHelperProtocol

    func resolve() -> ProductKeyDataSourceProtocol

    func resolve() -> SubscribeFactory

    func resolve() -> DateFormatterFactory

    func resolve() -> SubscribeJsonMapper

    // Mark: - FeatureToggle

    func resolve() -> FeatureManager

    func resolve() -> RemoteConfigRepository
}
