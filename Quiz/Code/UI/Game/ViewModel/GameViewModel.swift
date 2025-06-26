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
import Combine
import SwiftUI

@MainActor class GameViewModel: ObservableObject {
    
    static let conditionValueMin = 0
    
    typealias QuestSectionRepositoryProtocol = QuestRepositoryProtocol & SectionRepositoryProtocol
    
    private let loggerTag = "GameViewModel"
    
    @Published var isWarning: Bool = false
    @Published var isLoading: Bool = false
    @Published var quest: QuestUiModel?
    @Published var control: ControlModel = ControlModel(
        point: 0,
        progress: 0,
        conditionValue: GameProcess.lifeCondition,
        type: .life
    )
    @Published var answers: AnswersModel = AnswersModel(
        trueAnswerIndex: nil,
        selectedAnswerIndex: nil,
        isCorrect: false,
        answerButtonIsEnabled: true
    )
    @Published var scrollToTopAnimation: Bool = false
    @Published var startErrorVibration: Bool = false
    @Published var navigationState: GameNavigationState?
    
    // MARK: - External dependencies
    
    private let logger: Logger
    private let time: TimeCalculator
    private let abParser: AbQuestParser
    private let preferences: GamePreferences
    private let initialArgs: GameInitialArgs
    
    // MARK: - Internal dependencies
    
    private let dataManager: DataManagerProtocol
    private var gameProcess: GameProcessProtocol
    
    // MARK: - Internal state
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        logger: Logger,
        time: TimeCalculator,
        abParser: AbQuestParser,
        preferences: GamePreferences,
        contentRepository: QuestSectionRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        initialArgs: GameInitialArgs,
        aiTasksInteractor: AiTasksInteractor
    ) {
        self.logger = logger
        self.time = time
        self.abParser = abParser
        self.preferences = preferences
        self.initialArgs = initialArgs
        
        dataManager = DataManager(
            contentRepository: contentRepository,
            userRepository: userRepository,
            aiTasksInteractor: aiTasksInteractor,
            mode: initialArgs.mode
        )
        gameProcess = GameProcess(mode: initialArgs.mode)
    }
    
    func onAction(action: GameAction) {
        switch action {
        case .loadData:
            loadData()
        case .onScrollToTopAnimationEnded:
            onScrollToTopAnimationEnded()
        case .onErrorVibrationEnded:
            onErrorVibrationEnded()
        case .onNavigationHandled:
            onNavigationHandled()
        case .onAnswerSelected(userAnswer: let userAnswer, isSelected: _):
            onAnswerSelected(userAnswer: userAnswer)
        }
    }
    
    private func onAnswerSelected(userAnswer: String) {
        guard let quest = gameProcess.currentQuest else {
            return
        }
        
        let index = quest.answers.firstIndex(of: userAnswer)!
        showResult(
            quest: quest,
            userAnswerIndex: index
        )
        
        let transition: Double
        if gameProcess.gameMode == .sprint {
            transition = TransitionPreference.transition500.value
        } else {
            transition = preferences.transition
        }
        
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(transition * 1_000_000_000))
            
            self?.continueGame()
        }
    }
    
    private func showResult(quest: Quest, userAnswerIndex index: Int) {
        let userAnswer = quest.answers[index]
        let trueAnswer = quest.trueAnswer
        let isTrueAnswer = userAnswer.elementsEqual(trueAnswer)
        
        if isTrueAnswer {
            gameProcess.addSectionQuest()
            gameProcess.addRightQuest()
            
            gameProcess.incrementPoint()
            
            // Update UI
            self.control = ControlModel(
                point: gameProcess.point,
                progress: self.control.progress,
                conditionValue: self.control.conditionValue,
                type: self.control.type
            )
            self.answers = AnswersModel(
                trueAnswerIndex: nil,
                selectedAnswerIndex: index,
                isCorrect: true,
                answerButtonIsEnabled: false
            )
        } else {
            gameProcess.addErrorQuest()
            
            if gameProcess.gameMode == .sprint {
                gameProcess.specDecrementCondition()
            } else {
                gameProcess.decrementCondition()
            }
            
            // Update UI
            var condition = gameProcess.condition
            if condition < 0 {
                condition = 0
            }
            self.control = ControlModel(
                point: self.control.point,
                progress: self.control.progress,
                conditionValue: condition,
                type: gameProcess.getConditionType()
            )
            
            let trueAnswerIndex = quest.answers.firstIndex(of: trueAnswer)!
            self.answers = AnswersModel(
                trueAnswerIndex: trueAnswerIndex,
                selectedAnswerIndex: index,
                isCorrect: false,
                answerButtonIsEnabled: false
            )
            
            if preferences.isVibration {
                self.startErrorVibration = true
            }
        }
    }
    
    private func continueGame() {
        if gameProcess.condition > GameViewModel.conditionValueMin && gameProcess.isNext() {
            // Update UI
            self.answers = AnswersModel(
                trueAnswerIndex: nil,
                selectedAnswerIndex: nil,
                isCorrect: false,
                answerButtonIsEnabled: true
            )
            
            nextQuest()
        } else if gameProcess.isRewarded == false && gameProcess.condition <= GameViewModel.conditionValueMin && gameProcess.isNext() {
            self.gameProcess.isRewarded = true
            guard gameProcess.getConditionType() == .life else {
                return continueGame()
            }
            
            continueGame()
        } else {
            self.cancelTimer()
            self.finishGame()
        }
    }
    
    private func finishGame() {
        gameProcess.isFinished = true
        
        // Update ui
        self.answers = AnswersModel(
            trueAnswerIndex: self.answers.trueAnswerIndex,
            selectedAnswerIndex: self.answers.selectedAnswerIndex,
            isCorrect: self.answers.isCorrect,
            answerButtonIsEnabled: false
        )
        
        self.saveData()
        
        let sequeExtraArgs = EndSequeExtraArgs.Builder
            .with(mode: gameProcess.gameMode)
            .setThemeId(themeId: initialArgs.themeId)
            .setOldRecord(oldRecord: initialArgs.recordValue)
            .setPoint(point: gameProcess.point)
            .setCount(count: getQuestCount())
            .setErrorQuestIds(errorQuestIds: gameProcess.errorQuestIds)
            .setIsRewardedOpen(isRewardedOpen: gameProcess.isRewardedSuccess)
            .build()
        
        if sequeExtraArgs.gameMode != .error && sequeExtraArgs.point > sequeExtraArgs.oldRecord {
            navigationState = .navigateToProgressEnd(sequeExtraArgs)
        } else {
            navigationState = .navigateToGameEnd(sequeExtraArgs)
        }
    }
    
    private func getQuestCount() -> Int? {
        if gameProcess.gameMode == .sprint {
            return Record.sprintRecordMax
        } else {
            return gameProcess.questCount
        }
    }
    
    private func saveData() {
        Task { [weak self] in
            guard let self else { return }
            
            try await self.dataManager.saveErrorData(
                errorQuestIds: self.gameProcess.errorQuestIds,
                rightQuestIds: self.gameProcess.rightQuestIds
            )
            
            if self.gameProcess.point > self.initialArgs.recordValue {
                let point: Int
                if self.gameProcess.gameMode == .arcade {
                    point = try await self.dataManager.saveSectionData(
                        theme: self.initialArgs.themeId,
                        section: self.initialArgs.sectionId,
                        sectionQuestIds: self.gameProcess.sectionQuestIds
                    )
                } else {
                    point = self.gameProcess.point
                }
                
                if point != 0 {
                    try await self.dataManager.saveRecord(
                        theme: self.initialArgs.themeId,
                        point: point,
                        time: self.time.getTime()
                    )
                }
            }
        }
    }
    
    private func nextQuest() {
        guard !gameProcess.isFinished else {
            return
        }
        
        // 1. Init quest
        if gameProcess.isNext() {
            let id = gameProcess.next()
            initQuest(id: id)
        } else {
            finishGame()
        }
    }
    
    private func initQuest(id: Int?) {
        guard let id = id else {
            return completeQuest(quest: nil)
        }
        
        Task { [weak self] in
            guard let self else { return }

            let data = try await self.dataManager.loadQuest(
                id: id,
                theme: self.initialArgs.themeId
            )
            
            self.completeQuest(quest: data)
        }
    }
    
    private func completeQuest(quest: Quest?) {
        if let quest = quest, quest.isValid() {
            gameProcess.currentQuest = quest
            
            if abParser.isAbQuest(quest) {
                gameProcess.currentQuest = abParser.format(quest)
            }
            
            gameProcess.incrementQuestProgress()
            
            // Update UI
            self.control = ControlModel(
                point: self.control.point,
                progress: self.gameProcess.progress,
                conditionValue: self.control.conditionValue,
                type: self.control.type
            )
            
            showQuest()
        } else if gameProcess.isNext() {
            gameProcess.currentQuest = nil
            
            gameProcess.decrementQuestProgress()
            
            self.control = ControlModel(
                point: self.control.point,
                progress: self.gameProcess.progress,
                conditionValue: self.control.conditionValue,
                type: self.control.type
            )
            
            nextQuest()
        } else {
            finishGame()
        }
    }
    
    private func showQuest() {
        let quest = gameProcess.currentQuest!
        
        // Update UI
        self.scrollToTopAnimation = true
        self.quest = QuestUiModel(
            quest: quest.quest,
            answers: quest.answers
        )
    }
    
    private func onErrorVibrationEnded() {
        self.startErrorVibration = false
    }
    
    private func onScrollToTopAnimationEnded() {
        self.scrollToTopAnimation = false
    }
    
    private func onNavigationHandled() {
        navigationState = nil
    }
    
    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            
            self.showLoading()
            
            let themeId = self.initialArgs.themeId
            
            let isSort = self.preferences.isSorting
            let data = try await self.dataManager.loadQuestIds(
                theme: themeId,
                section: self.initialArgs.sectionId,
                isSort: isSort
            )
            
            if let data {
                self.gameProcess.questIds = data
                self.gameProcess.questCount = data.count
                self.startGame()
                self.showData()
            } else {
                self.showWarningState()
            }
        }
    }
    
    // MARK: - Game control func
    
    private func startGame() {
        guard gameProcess.isNext() else {
            showWarningState()
            return
        }
        
        if gameProcess.gameMode == .sprint {
            startTimer()
        }
        
        nextQuest()
    }
    
    private func getControl() -> ControlModel {
        switch gameProcess.getConditionType() {
        case .life:
            return ControlModel(
                point: 0,
                progress: 0,
                conditionValue: GameProcess.lifeCondition,
                type: .life
            )
        case .time:
            return ControlModel(
                point: 0,
                progress: 0,
                conditionValue: GameProcess.timeCondition,
                type: .life
            )
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        if timer != nil {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.updateTimer()
                
                let isValidCondition = self.gameProcess.isValidCondition()
                if !isValidCondition {
                    self.cancelTimer()
                }
            }
        }
        timer?.tolerance = 0.1
    }
    
    @objc func updateTimer() {
        gameProcess.decrementCondition()
        let condition = gameProcess.condition
        self.control = ControlModel(
            point: self.control.point,
            progress: self.control.progress,
            conditionValue: condition,
            type: .time
        )
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: Private state funcs
    
    private func showLoading() {
        isLoading = true
        isWarning = false
    }
    
    private func showWarningState() {
        isLoading = false
        isWarning = true
    }
    
    private func showData() {
        isLoading = false
        isWarning = false
    }
}
