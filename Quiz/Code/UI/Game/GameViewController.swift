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
import SwiftUI
import AppTrackingTransparency
import AudioToolbox.AudioServices
import Combine

private let recordSegueNext = "segueGameToRecord"
private let endSegueNext = "segueGameToEnd"

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameNavigationItem: GameNavigationItem!
    
    var sequeExtraArgs: GameSequeExtraArgs?
    
    private var viewModel: GameViewModel!
    
    private var cancellables = Set<AnyCancellable>()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = createHostController()
        let swiftUiView = hostingController.view!
        swiftUiView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(swiftUiView)
        
        NSLayoutConstraint.activate([
            swiftUiView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUiView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swiftUiView.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftUiView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        hostingController.didMove(toParent: self)
                        
        viewModel?.onAction(action: .loadData)
        
        bindControl()
    }
    
    // MARK: - Binding

    private func bindControl() {
        viewModel.$control
            .receive(on: DispatchQueue.main)
            .sink { [weak self] control in
                guard let self = self else { return }
                                
                setupConditionView(type: control.type)
                updatePoint(value: control.point)
                updateCondition(
                    type: control.type,
                    value: control.conditionValue
                )
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation item settings
    
    private func setupConditionView(type: GameProcess.ConditionType) {
        switch type {
        case .life: gameNavigationItem.delgate = LifeGameNavigationItemDelegate()
        case .time: gameNavigationItem.delgate = TimeGameNavigationItemDelegate()
        }
        gameNavigationItem?.setupCondition()
    }
    
    private func updatePoint(value: Int) {
        gameNavigationItem?.updatePoint(value: value)
    }
    
    private func updateCondition(type: GameProcess.ConditionType, value: Int) {
        var condition = value
        if condition < 0 {
            condition = 0
        }
        gameNavigationItem?.updateCondition(value: condition)
    }
    
    // MARK: Other platform func
    
    private func vibrate() {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
    }
    
    // MARK: - Private
    
    private func createHostController() -> UIHostingController<GameScreen> {
        viewModel = GameViewModel(
            logger: IocContainer.app.resolve(),
            time: IocContainer.app.resolve(),
            abParser: IocContainer.app.resolve(),
            preferences: IocContainer.app.resolve(),
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            initialArgs: GameInitialArgs(
                mode: sequeExtraArgs!.gameMode!,
                themeId: sequeExtraArgs!.themeId!,
                sectionId: sequeExtraArgs!.sectionId,
                recordValue: sequeExtraArgs!.record
            ),
            aiTasksInteractor: IocContainer.app.resolve()
        )
        
        let view = GameScreen(
            onNavigateToProgressEnd: { [weak self] args in
                guard let self = self else { return }
                self.performSegue(withIdentifier: recordSegueNext, sender: args)

            },
            onNavigateToGameEnd: {  [weak self] args in
                guard let self = self else { return }
                self.performSegue(withIdentifier: endSegueNext, sender: args)
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sequeData = sender as? EndSequeExtraArgs else {
            return
        }

        if let destinition = segue.destination as? UIViewController & EndViewProtocol {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            destinition.sequeExtraArgs = sequeData
        }
    }
}
