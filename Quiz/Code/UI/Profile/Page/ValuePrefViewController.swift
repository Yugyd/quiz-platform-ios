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

private let reuseIdentifier = "ValueCell"

class ValuePrefViewController: UITableViewController, ValuePrefViewProtocol {
    var sequePrefModeExtraArg: ValuePrefMode?

    fileprivate var presenter: ValuePrefPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequePrefModeExtraArg == nil {
            setEmptyStub()
            return
        }

        initPresenter()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.loadCurrentValue()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.data.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = presenter?.data[indexPath.row]

        let selected = tableView.indexPathForSelectedRow?.row ?? -1
        if selected == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.changePref(index: indexPath.row)
    }

    // MARK: - ValuePrefViewProtocol

    func updateTable() {
        tableView?.reloadData()
    }

    func selectRow(index: Int) {
        let indexPath = IndexPath(row: index, section: 0);
        tableView?.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        tableView(self.tableView, didSelectRowAt: indexPath)
    }

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    // MARK: - Private func

    private func initPresenter() {
        presenter = ValuePrefPresenter(prefMode: sequePrefModeExtraArg!)
        presenter?.attachRootView(rootView: self)
        presenter?.loadData()
    }
}
