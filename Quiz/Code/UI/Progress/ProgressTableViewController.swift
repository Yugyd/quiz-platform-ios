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

private let segueNext = "segueProgressToPage"

class ProgressTableViewController: UITableViewController, ProgressViewProtocol, ProgressUpdateCallback {

    fileprivate var presenter: ProgressPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        initPresenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter?.loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let headerView = tableView.tableHeaderView else {
            return
        }

        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.themes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProgressViewCell.reuseIdentifier, for: indexPath) as! ProgressViewCell

        if let theme = presenter?.themes[indexPath.row] {
            let progressPercent = presenter?.calculateProgress(point: theme.point) ?? 0
            let levelDegree = LevelDegree.instanceByProgress(progressPercent: progressPercent)
            cell.updateData(
                    title: theme.name,
                    levelDegree: LevelDegree.getTitle(levelDegree: levelDegree),
                    progressPercent: progressPercent
            )
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: segueNext, sender: indexPath)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }

        if let parentDestinition = segue.destination as? UINavigationController {
            if let destinition = parentDestinition.viewControllers[0] as? ProgressPageTableViewController {
                destinition.hidesBottomBarWhenPushed = true
                destinition.sequeExtraThemeIdArg = presenter?.themes[indexPath.row].id
                destinition.updateCallback = self
                destinition.navigationItem.title = presenter?.themes[indexPath.row].name
            }
        }
    }

    // MARK: - Progress view protocol

    func updateTable() {
        tableView?.reloadData()
    }

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    func updateTableHeader(progressPercent: Int, levelDegree: LevelDegree, progressLevel: ProgressLevel) {
        if let header = tableView?.tableHeaderView as? ProgressHeaderView {
            let tintColor = ProgressColor.getColorByQualifier(level: progressLevel)
            header.updateData(
                    progressColor: tintColor,
                    progressPercent: progressPercent,
                    levelDegree: LevelDegree.getTitle(levelDegree: levelDegree)
            )
        }
    }

    // MARK: - ProgressUpdateCallback

    func update() {
        presenter?.loadData()
    }

    // MARK: - Setup UI

    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        presenter = ProgressPresenter(contentRepository: contentRepository,
                userRepository: userRepository)
        presenter?.attachView(rootView: self)
    }
}
