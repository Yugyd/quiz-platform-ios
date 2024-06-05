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

private let segueSectionToGame = "segueSectionToGame"

class SectionCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SectionSegueProtocol, SectionViewProtocol {
    
    var sequeExtraThemeIdArg: Int?
    
    fileprivate var presenter: SectionPresenterProtocol?
    
    private let sectionInserts = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if sequeExtraThemeIdArg == nil {
            setEmptyStub()
            return
        }
        
        initPresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.loadData()
    }
    
    // MARK: - IBAction
    
    @IBAction func unwindToSectionViewController(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.sections.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SectionViewCell.reuseIdentifier, for: indexPath) as! SectionViewCell
        
        // Configure the cell
        if let section = presenter?.sectionWithLevels[indexPath.row] {
            let isLatest = presenter?.isLatestSection(id: section.item.id)
            
            cell.setNumTitle(id: section.item.id)
            if isLatest == nil || isLatest! > 0 {
                cell.lockCell()
            } else {
                cell.setProgressBar(level: section.level)
            }
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            itemPerRow = CGFloat(4)
        } else {
            itemPerRow = CGFloat(3)
        }
        let paddingSpace = sectionInserts.left * (itemPerRow + 1)
        
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemPerRow
        
        let aspectRatio = CGFloat(1.0)
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
        
        if let section = presenter?.sectionWithLevels[indexPath.row] {
            let isLatest = presenter?.isLatestSection(id: section.item.id)
            
            if isLatest != nil && isLatest! <= 0 {
                performSegue(withIdentifier: segueSectionToGame, sender: indexPath)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = sender as? IndexPath else {
            return
        }
        
        let section = presenter?.sections[indexPath.row]
        let theme = presenter?.theme
        
        if let destinition = segue.destination as? GameViewController {
            destinition.hidesBottomBarWhenPushed = true
            destinition.sequeExtraArgs = GameSequeExtraArgs.Builder
                .with(mode: .arcade, themeId: theme?.id)
                .setSectionId(sectionId: section?.id)
                .setRecord(record: section?.point)
                .build()
        }
    }
    
    // MARK: - SectionViewProtocol
    
    func updateCollection() {
        collectionView.reloadData()
    }
    
    func updateTitle(title: String) {
        navigationItem.title = title
    }
    
    func setEmptyStub() {
        present(AlertBuilder.createEmptyContent().build(), animated: true, completion: nil)
    }
    
    func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //    MARK: - Private section
    
    private func initPresenter() {
        let contentRepository: ContentRepository = IocContainer.app.resolve()
        let userRepository: UserRepository = IocContainer.app.resolve()
        
        presenter = SectionPresenter(
            contentRepository: contentRepository,
            userRepository: userRepository,
            themeId: sequeExtraThemeIdArg!,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
            
        )
        presenter?.attachView(rootView: self)
    }
}
