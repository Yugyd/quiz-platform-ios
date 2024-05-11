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

class FileRepositoryImpl: FileRepository {
    
    private let mockFileName = "example.txt"
    private let mockStubText = """
        [category]

        1
        Категория А Variant
        Описание А Variant

        2
        Категория Б Variant
        Описание Б Variant
        https://test.com/test.png

        3
        Категория Б Variant
        Описание Б Variant
        https://raw.githubusercontent.com/Yugyd/quiz-platform/master/app/src/main/res/mipmap-xxxhdpi/ic_launcher.webp

        [quest]

        Вопрос 1
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        1
        1

        Вопрос 2
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        2
        1

        Вопрос 3
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        2
        2

        Вопрос 4
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        3
        1

        Вопрос 5
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        3
        2

        Вопрос 5
        Ответ 1
        Ответ 2
        Ответ 3
        Ответ 4
        3
        3
        3
        """

    func saveTextToLocalStorage(fileName: String, fileContents: String) -> String? {
        // TODO: Replace prod impl
        let fileURL = try! FileManager
            .default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent(fileName)
        return fileURL.absoluteString
    }
    
    func readTextFromFile(fileName: String) -> String {
        // TODO: Replace prod impl
        return mockStubText
    }
    
    func getFileName(uri: String) -> String {
        // TODO: Replace prod impl
        return mockFileName
    }
}
