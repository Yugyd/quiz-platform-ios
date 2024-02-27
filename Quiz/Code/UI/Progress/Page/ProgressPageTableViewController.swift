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

class ProgressPageTableViewController: UITableViewController, ProgressPageSegueProtocol, ProgressPageViewProtocol {

    var sequeExtraThemeIdArg: Int?

    @IBOutlet weak var resetBarButtonItem: UIBarButtonItem!

    weak var updateCallback: ProgressUpdateCallback?

    private var progressPresenter: ProgressPagePresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        if sequeExtraThemeIdArg == nil {
            setEmptyStub()
            return
        }

        initPresenter()
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

    // MARK: - Action binndera

    @IBAction func actionResetProgress(_ sender: UIBarButtonItem) {
        progressPresenter?.resetProgress()
    }

    @IBAction func actionClosePage(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return progressPresenter?.modes.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ModeViewCell.reuseIdentifier, for: indexPath) as! ModeViewCell

        if let mode = progressPresenter?.modes[indexPath.row], let theme = progressPresenter?.theme {
            let progressPercent = progressPresenter?.calculateProgress(mode: mode, point: theme.point) ?? 0
            let progressTitle = progressPresenter?.getProgressTitle(mode: mode, point: theme.point)
            cell.updateData(title: mode.title, progressPercent: progressPercent, progressTitle: progressTitle)
        }
        return cell
    }

    // MARK: - ProgressPageViewProtocol

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    func enableResetButton(isEnabled: Bool) {
        resetBarButtonItem.isEnabled = isEnabled
    }

    func updateTable() {
        tableView?.reloadData()
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

    // MARK: - Private func

    func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()

        progressPresenter = ProgressPagePresenter(contentRepository: contentRepository,
                userRepository: userRepository,
                themeId: sequeExtraThemeIdArg!)
        progressPresenter?.attachView(rootView: self)
        progressPresenter?.loadData()
    }
}
