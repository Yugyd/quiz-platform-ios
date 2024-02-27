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

private let segueThemeToGame = "segueThemeToGame"
private let segueThemeToSection = "segueThemeToSection"

class ThemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ThemeSegmentedViewProtocol, ThemeViewProtocol {

    fileprivate var presenter: ThemePresenterProtocol?

    private let sectionInserts = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)

    override func viewDidLoad() {
        super.viewDidLoad()

        initPresenter()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        presenter?.loadData()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.themes.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThemeViewCell.reuseIdentifier, for: indexPath) as! ThemeViewCell

        if let theme = presenter?.themes[indexPath.row] {
            let progress = presenter?.calculateProgress(point: theme.point) ?? 0
            cell.updateData(image: theme.imageName, title: theme.title, progress: progress)
        }
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemPerRow: CGFloat
        let paddingSpace: CGFloat
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            itemPerRow = CGFloat(2)//
            paddingSpace = sectionInserts.left * (itemPerRow + 1)//
        } else {
            itemPerRow = CGFloat(1)//
            paddingSpace = sectionInserts.left + sectionInserts.right
        }

        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemPerRow

        let aspectRatio = CGFloat(1.25)
        let height = widthPerItem / aspectRatio

        return CGSize(width: widthPerItem, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(16)
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presenter?.startSegue(sender: indexPath)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }

        let theme = presenter?.themes[indexPath.row]

        if segue.identifier == segueThemeToGame {
            if let destinition = segue.destination as? GameViewController {
                destinition.hidesBottomBarWhenPushed = true

                var record: Int? = nil
                if let point = theme?.point {
                    record = presenter?.progressCalculator?.getRecord(point: point)
                }
                destinition.sequeExtraArgs = GameSequeExtraArgs.Builder
                        .with(mode: presenter?.gameMode, themeId: theme?.id)
                        .setRecord(record: record)
                        .build()
            }
        } else if segue.identifier == segueThemeToSection {
            if let destinition = segue.destination as? SectionCollectionViewController {
                destinition.sequeExtraThemeIdArg = theme?.id

                if let theme = theme {
                    destinition.navigationItem.title = theme.title
                }
            }
        }
    }

    //    MARK: - ThemeViewProtocol

    func updateCollection() {
        collectionView.reloadData()
    }

    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }

    func startSegue(startMode: StartMode, sender: IndexPath) {
        switch startMode {
        case .game:
            performSegue(withIdentifier: segueThemeToGame, sender: sender)
        case .section:
            performSegue(withIdentifier: segueThemeToSection, sender: sender)
        }
    }

    //    MARK: - ThemeSegmentedViewProtocol

    func changeMode(mode: Mode) {
        presenter?.gameMode = mode
        updateCollection()
    }

    //    MARK: - Private section

    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()

        presenter = ThemePresenter(contentRepository: contentRepository,
                userRepository: userRepository)
        presenter?.attachRootView(rootView: self)
        presenter?.gameMode = .arcade // Default mode (first index)
    }
}
