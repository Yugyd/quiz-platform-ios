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

class GamePresenter: GamePresenterProtocol {

    static let conditionValueMin = 0

    typealias QuestSectionRepositoryProtocol = QuestRepositoryProtocol & SectionRepositoryProtocol

    var themeId: Int
    var sectionId: Int?
    var recordValue: Int

    fileprivate weak var rootView: GameViewProtocol?

    private var timer: Timer?

    private var dataManager: DataManagerProtocol
    private var gameProcess: GameProcessProtocol

    private var time: TimeCalculator
    private var abParser: AbQuestParser
    private var preferences: Preferences

    init(contentRepository: QuestSectionRepositoryProtocol,
         userRepository: UserRepositoryProtocol,
         mode: Mode,
         themeId: Int,
         sectionId: Int?,
         record: Int) {
        self.themeId = themeId
        self.sectionId = sectionId
        self.recordValue = record

        self.dataManager = DataManager(contentRepository: contentRepository, userRepository: userRepository, mode: mode)
        self.gameProcess = GameProcess(mode: mode)

        self.time = TimeCalculator()
        self.abParser = DefaultAbQuestParser()
        self.preferences = GamePreferences(preferences: UserPreferences())
    }

    // MARK: - GamePresenterProtocol - view

    func attachRootView(rootView: GameViewProtocol) {
        self.rootView = rootView
    }

    func setupBarViews() {
        rootView?.updatePoint(value: 0)
        rootView?.updateProgress(value: 0)

        switch gameProcess.getConditionType() {
        case .life:
            rootView?.setupConditionView(type: .life)
            rootView?.updateCondition(type: .life, value: GameProcess.lifeCondition)
        case .time:
            rootView?.setupConditionView(type: .time)
            rootView?.updateCondition(type: .time, value: GameProcess.timeCondition)
        }
    }

    // MARK: - GamePresenterProtocol - interactive

    func answer(index: Int) {
        guard let quest = gameProcess.currentQuest else {
            return
        }

        showResult(quest: quest, userAnswerIndex: index)

        let transition: Double
        if gameProcess.gameMode == .sprint {
            transition = TransitionPreference.transition500.value
        } else {
            transition = preferences.transition
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + transition) { [weak self] in
            self?.continueGame()
        }
    }

    // MARK: - GamePresenterProtocol - data

    func loadData() {
        DispatchQueue.global().async { [weak self] in
            guard let themeId = self?.themeId else {
                self?.rootView?.setEmptyStub()
                return
            }

            let isSort = self?.preferences.isSorting ?? false // Use default class
            let data: [Int]? = self?.dataManager.loadQuestIds(theme: themeId, section: self?.sectionId, isSort: isSort)

            if let data = data {
                DispatchQueue.main.async { [weak self] in
                    self?.gameProcess.questIds = data
                    self?.gameProcess.questCount = data.count
                    self?.startGame()
                }
            } else {
                self?.rootView?.setEmptyStub()
            }
        }
    }

    func saveFastData() {
        DispatchQueue.global().async { [weak self] in
            self?.dataManager.saveErrorData(errorQuestIds: self?.gameProcess.errorQuestIds,
                    rightQuestIds: self?.gameProcess.rightQuestIds)
        }
    }

    func saveData() {
        DispatchQueue.global().async { [weak self] in
            if let self = self {
                self.dataManager.saveErrorData(errorQuestIds: self.gameProcess.errorQuestIds,
                        rightQuestIds: self.gameProcess.rightQuestIds)

                if self.gameProcess.point > self.recordValue {
                    let point: Int
                    if self.gameProcess.gameMode == .arcade {
                        point = self.dataManager.saveSectionData(theme: self.themeId,
                                section: self.sectionId,
                                sectionQuestIds: self.gameProcess.sectionQuestIds)
                    } else {
                        point = self.gameProcess.point
                    }

                    if point != 0 {
                        self.dataManager.saveRecord(theme: self.themeId, point: point, time: self.time.getTime())
                    }
                }
            }
        }
    }

    // MARK: - GamePresenterProtocol - Reward

    func handleReward(isSuccess: Bool) {
        if isSuccess {
            gameProcess.isRewardedSuccess = true
            gameProcess.addExtraCondition()
        }
        continueGame()
    }

    // MARK: - Timer

    @objc func updateTimer() {
        gameProcess.decrementCondition()
        let condition = gameProcess.condition
        rootView?.updateCondition(type: .time, value: condition)
    }

    private func startTimer() {
        if timer != nil {
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()

            let isValidCondition = self?.gameProcess.isValidCondition() ?? false
            if !isValidCondition {
                self?.cancelTimer()
            }

        }
        timer?.tolerance = 0.1
    }

    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Game control func

    private func startGame() {
        guard gameProcess.isNext() else {
            rootView?.setEmptyStub()
            return
        }

        if gameProcess.gameMode == .sprint {
            startTimer()
        }

        nextQuest()
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

        DispatchQueue.global().async { [weak self] in
            let data = self?.dataManager.loadQuest(id: id)

            DispatchQueue.main.async { [weak self] in
                self?.completeQuest(quest: data)
            }
        }
    }

    private func completeQuest(quest: Quest?) {
        if let quest = quest, quest.isValid() {
            gameProcess.currentQuest = quest

            if abParser.isAbQuest(quest) {
                gameProcess.currentQuest = abParser.format(quest)
            }

            gameProcess.incrementQuestProgress()
            rootView?.updateProgress(value: gameProcess.progress)

            showQuest()
        } else if gameProcess.isNext() {
            gameProcess.currentQuest = nil

            gameProcess.decrementQuestProgress()
            rootView?.updateProgress(value: gameProcess.progress)

            nextQuest()
        } else {
            finishGame()
        }
    }

    private func showQuest() {
        let quest = gameProcess.currentQuest!

        rootView?.updateQuestContent(quest: quest.quest)
        rootView?.updateAnswerContent(answers: quest.answers)
        rootView?.setupViews()
    }

    private func showResult(quest: Quest, userAnswerIndex index: Int) {
        let userAnswer = quest.answers[index]
        let trueAnswer = quest.trueAnswer
        let isTrueAnswer = userAnswer.elementsEqual(trueAnswer)

        if isTrueAnswer {
            gameProcess.addSectionQuest()
            gameProcess.addRightQuest()

            gameProcess.incrementPoint()

            rootView?.updatePoint(value: gameProcess.point)
            rootView?.highlightSelectedAnswer(index: index, isTrueAnswer: true)
        } else {
            gameProcess.addErrorQuest()

            if gameProcess.gameMode == .sprint {
                gameProcess.specDecrementCondition()
            } else {
                gameProcess.decrementCondition()
            }

            rootView?.updateCondition(type: gameProcess.getConditionType(), value: gameProcess.condition)
            rootView?.highlightSelectedAnswer(index: index, isTrueAnswer: false)

            if let trueAnswerIndex = quest.answers.firstIndex(of: trueAnswer) {
                rootView?.showTrueAnswer(index: trueAnswerIndex)
            }

            if preferences.isVibration {
                rootView?.vibrate()
            }
        }
    }

    private func continueGame() {
        if gameProcess.condition > GamePresenter.conditionValueMin && gameProcess.isNext() {
            rootView?.clearAnswerForms()
            rootView?.blockAnswers(isBlocked: false)

            nextQuest()
        } else if gameProcess.isRewarded == false && gameProcess.condition <= GamePresenter.conditionValueMin && gameProcess.isNext() {
            gameProcess.isRewarded = true
            guard gameProcess.getConditionType() == .life else {
                return continueGame()
            }
            if let rootView = rootView as? AdGameRewardedProtocol {
                rootView.showRewardedAdDialog()
            } else {
                return continueGame()
            }
        } else {
            cancelTimer()
            finishGame()
        }
    }

    private func finishGame() {
        gameProcess.isFinished = true
        rootView?.blockAnswers(isBlocked: true)
        saveData()

        let args = EndSequeExtraArgs.Builder
                .with(mode: gameProcess.gameMode)
                .setThemeId(themeId: themeId)
                .setOldRecord(oldRecord: recordValue)
                .setPoint(point: gameProcess.point)
                .setCount(count: getQuestCount())
                .setErrorQuestIds(errorQuestIds: gameProcess.errorQuestIds)
                .setIsRewardedOpen(isRewardedOpen: gameProcess.isRewardedSuccess)
                .build()

        rootView?.finish(sequeExtraArgs: args)
    }

    private func getQuestCount() -> Int? {
        if gameProcess.gameMode == .sprint {
            return Record.sprintRecordMax
        } else {
            return gameProcess.questCount
        }
    }
}
