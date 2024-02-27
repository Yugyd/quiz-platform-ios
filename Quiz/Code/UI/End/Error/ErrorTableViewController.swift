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

import UIKit

class ErrorTableViewController: UITableViewController, ErrorTableViewProtocol {

    var sequeExtraErrorIdsArg: Set<Int>?

    fileprivate var presenter: ErrorPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequeExtraErrorIdsArg == nil {
            setEmptyStub()
            return
        }

        initPresenter()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return presenter?.errors?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ErrorViewCell.reuseIdentifier, for: indexPath) as! ErrorViewCell

        if let error = presenter?.errors?[indexPath.row] {
            cell.updateData(quest: error.quest, answer: error.trueAnswer)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let error = presenter?.errors?[indexPath.row] {
            Web.searchInGoogle(error: error)
        }
    }

    // MARK: - ErrorViewProtocol

    func updateTable() {
        tableView?.reloadData()
    }

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    // MARK: - Private func

    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let lineSepartorFormatter: LineSeparatorFormatter = IocContainer.app.resolve()
        presenter = ErrorPresenter(repository: contentRepository, questFormatter: lineSepartorFormatter, errorIds: sequeExtraErrorIdsArg!)
        presenter?.attachView(rootView: self)
        presenter?.loadData()
    }
}
