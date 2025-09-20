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

private let promoVcIdentifier = "ProPromoViewController"

class ProPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ProPageViewProtocol {

    var promoControllers: [ProPromoViewController]!

    private var presenter: ProPagePresenterProtocol?
    private var featureManager: FeatureManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        initPresenter()

        self.dataSource = self
        self.delegate = self
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        presenter?.cancelTimer()

        let index = (viewController as? ProPromoViewController)?.index ?? 0
        let newIndex = index - 1

        if newIndex < 0 {
            return nil
        } else {
            return promoControllers[newIndex]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as? ProPromoViewController)?.index ?? 0
        let newIndex = index + 1

        if newIndex >= promoControllers.count {
            return nil
        } else {
            return promoControllers[newIndex]
        }
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return promoControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return getCurrentPageIndex()
    }

    // MARK: - ProPageViewProtocol

    func updatePager() {
        let correctVc = initViewController(for: 0)

        if featureManager?.isFeatureEnabled(FeatureToggle.ad) == true {
            let adVc = initViewController(for: 1)
            promoControllers = [correctVc, adVc]
        } else {
            promoControllers = [correctVc]
        }

        setViewControllers([promoControllers[0]], direction: .forward, animated: true, completion: nil)
        presenter?.startTimer()
    }

    func goNextPage() {
        guard let currentViewController = self.viewControllers?.first else {
            return
        }
        guard let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) else {
            return
        }
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }

    func getCurrentPageIndex() -> Int {
        guard let currentViewController = self.viewControllers?.first else {
            return -1
        }
        return (currentViewController as! ProPromoViewController).index
    }

    // MARK: - Private func

    private func initPresenter() {
        featureManager = IocContainer.app.resolve()
        presenter = ProPagePresenter()
        presenter?.attachView(view: self)
        presenter?.loadData()
    }

    private func initViewController(for index: Int) -> ProPromoViewController {
        let vc = (storyboard?.instantiateViewController(withIdentifier: promoVcIdentifier) as! ProPromoViewController)
        vc.index = index
        vc.data = presenter?.promos[index]
        return vc
    }
}
