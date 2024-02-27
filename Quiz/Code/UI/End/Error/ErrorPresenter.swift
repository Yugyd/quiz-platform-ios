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

class ErrorPresenter: ErrorPresenterProtocol {

    var errorIds: Set<Int>
    var errors: [ErrorQuest]?

    weak fileprivate var rootView: ErrorTableViewProtocol?

    private let repository: QuestRepositoryProtocol
    private let questFormatter: SymbolFormatter // Line separtor formatter

    init(repository: QuestRepositoryProtocol, questFormatter: SymbolFormatter, errorIds: Set<Int>) {
        self.repository = repository
        self.questFormatter = questFormatter
        self.errorIds = errorIds
    }

    func attachView(rootView: ErrorTableViewProtocol) {
        self.rootView = rootView
    }

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            guard let errorIds = self?.errorIds else {
                self?.rootView?.setEmptyStub()
                return
            }

            if let data = self?.repository.getErrors(ids: errorIds) {
                DispatchQueue.main.async { [weak self] in
                    self?.errors = data.map {
                        if let quest = self?.questFormatter.format(data: $0.quest) {
                            return ErrorQuest(id: $0.id, quest: quest, trueAnswer: $0.trueAnswer)
                        } else {
                            return $0
                        }
                    }

                    self?.rootView?.updateTable()
                }
            }
        }
    }
}
