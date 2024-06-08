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

class RemoteConfigRepositoryImpl: RemoteConfigRepository {

    private let defaultEnLocale = Locale(identifier: "en")

    private let telegramConfigs = [
        TelegramConfig(
                locale: "ru_RU",
                gameEnd: GameEnd(
                        buttonTitle: "Подписаться",
                        message: "Вам понравилось? Подпишитесь на Telegram-канал, вас ждут ежедневные вопросы и много интересного!",
                        title: "Новый рекорд!"
                ),
                links: [],
                mainPopup: MainPopup(
                        buttonTitle: "Подписаться",
                        message: "Вас ждут ежедневные вопросы и много интересного!",
                        title: "Мы открыли Telegram-канал!"
                ),
                profileCell: ProfileCell(
                        message: "Ежедневные вопросы и обратная связь",
                        title: "Telegram-канал"
                ),
                trainPopup: TrainPopup(
                        message: "Вас ждут ежедневные вопросы и много интересного!",
                        negativeButtonTitle: "Позже",
                        positiveButtonTitle: "Подписаться",
                        title: "Мы открыли Telegram-канал!"
                )
        ),
        TelegramConfig(
                locale: "en",
                gameEnd: GameEnd(
                        buttonTitle: "Follow",
                        message: "Did you like it? Subscribe to the Telegram channel, daily questions and a lot of interesting things await you!",
                        title: "New record!"
                ),
                links: [],
                mainPopup: MainPopup(
                        buttonTitle: "Follow",
                        message: "Daily questions and a lot of interesting things await you!",
                        title: "We have opened a telegram channel!"
                ),
                profileCell: ProfileCell(
                        message: "Daily questions and feedback",
                        title: ""
                ),
                trainPopup: TrainPopup(
                        message: "Daily questions and a lot of interesting things await you!",
                        negativeButtonTitle: "Later",
                        positiveButtonTitle: "Follow",
                        title: "We have opened a telegram channel!"
                )
        ),
    ]

    func fetchTelegramConfig() -> TelegramConfig? {
        let result = telegramConfigs.first { config in
            let configLocale = Locale(identifier: config.locale)
            return configLocale.identifier == Locale.current.identifier
        }

        if result == nil {
            return telegramConfigs.first { config in
                let configLocale = Locale(identifier: config.locale)
                return configLocale.identifier == defaultEnLocale.identifier
            }
        } else {
            return result
        }
    }
}
