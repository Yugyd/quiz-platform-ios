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

import XCTest
import UIKit
@testable import Quiz

// Async Test Classes
enum AsyncTestMode {
    case testShowQuest
    case testTrueAnswer
    case testFalseAnswer

    case testFinish
}

protocol AsyncTestProtocol {

    func finishAsyncTest(mode: AsyncTestMode!)
}

class GamePresenterTest: XCTestCase, AsyncTestProtocol {

    var asyncMode: AsyncTestMode!
    var expectation: XCTestExpectation!

    // Test Variables

    let testMode: Mode = .arcade
    let testTheme: Int = 2 // def 1
    let testSection: Int = 1
    let testRecord: Int = 9
    let testPoint: Int = 1
    let testTransition = 0.0 // def 0.0
    let testTimeout = 1000.0 // def 1000.0

    var view: ViewMock!
    //var uiVc: GameViewController!

    var presenter: GamePresenter!
    var contentRepo: ContentRepositoryInterceptorMock!
    var userRepo: UserRepository!
    var dataManager: DataManager!

    override func setUp() {
        //uiVc = GameViewController()
        view = ViewMock(presenter: self/*, vc: uiVc*/)

        let pref = UserPreferences()
        pref.transition = testTransition
        pref.isVibration = true

        contentRepo = ContentRepositoryInterceptorMock(contentDb: IocContainer.app.resolve())
        userRepo = IocContainer.app.resolve()
        dataManager = DataManager(contentRepository: contentRepo, userRepository: userRepo, mode: testMode)

        presenter = GamePresenter(contentRepository: contentRepo, userRepository: userRepo, mode: testMode, themeId: testTheme, sectionId: testSection, record: testRecord)
        presenter.attachRootView(rootView: view)
    }

    override func tearDown() {
        //uiVc = nil
        view = nil
        contentRepo = nil
        _ = userRepo.reset()
        userRepo = nil
        presenter = nil
        asyncMode = nil
        expectation = nil

        let pref = UserPreferences()
        pref.transition = TransitionPreference.defaultTransition.value
        pref.isVibration = false
    }

    func testInitPresenter() {
        XCTAssertEqual(presenter.themeId, testTheme)
        XCTAssertEqual(presenter.sectionId, testSection)
        XCTAssertEqual(presenter.recordValue, testRecord)
    }

    // attachRootView
    func testAttachRootView() {
        presenter.attachRootView(rootView: view)
    }

    // setupBarViews
    func testSetupBarViews() {
        presenter.setupBarViews()

        XCTAssertTrue(view.isUpdatePoint)
        XCTAssertEqual(view.point, "0")

        XCTAssertTrue(view.isUpdateProgress)
        XCTAssertEqual(view.progress, 0)

        XCTAssertTrue(view.isSetupConditionView)
        if testMode == .sprint {
            XCTAssertEqual(view.conditionType, GameProcess.ConditionType.time)
        } else {
            XCTAssertEqual(view.conditionType, GameProcess.ConditionType.life)
        }

        XCTAssertTrue(view.isUpdateCondition)
        if testMode == .sprint {
            XCTAssertEqual(view.conditionType, GameProcess.ConditionType.time)
        } else {
            XCTAssertEqual(view.conditionType, GameProcess.ConditionType.life)
        }

        switch view.conditionType {
        case .life:
            XCTAssertEqual(view.condition, GameProcess.lifeCondition)
        case .time:
            XCTAssertEqual(view.condition, GameProcess.timeCondition)
        case .none:
            XCTFail()
        }
    }

    // loadData
    // Show quest
    func testLoadDataShowQuest() {
        asyncMode = .testShowQuest
        expectation = XCTestExpectation(description: "Game load data")

        presenter.setupBarViews()
        view.isUpdateProgress = false

        presenter.loadData()

        wait(for: [expectation], timeout: testTimeout)
    }

    // saveFastData -> Inner Cycle Test
    func testSaveFastData() {
        presenter.saveFastData()
    }

    // saveData -> Inner Cycle Test
    func testSaveData() {
        presenter.saveData()
    }

    // answer
    func testTrueAnswer() {
        asyncMode = .testTrueAnswer
        startAnswerTest()
    }

    // answer
    func testFalseAnswer() {
        asyncMode = .testFalseAnswer
        startAnswerTest()
    }

    // (Inner Cycle Test)
    func testCycleAnswer() {
        asyncMode = .testFinish
        startAnswerTest()
    }

    private func startAnswerTest() {
        expectation = XCTestExpectation(description: "Game test true answer")

        presenter.setupBarViews()
        view.isUpdateProgress = false

        presenter.loadData()

        wait(for: [expectation], timeout: testTimeout)
    }

    func hookTestAnswer() {
        switch asyncMode {
        case .testTrueAnswer, .testFinish:
            let index = view.answers!.firstIndex {
                return $0 == contentRepo.quest.trueAnswer
            }!
            presenter.answer(index: index)
        case .testFalseAnswer:
            let index = view.answers!.firstIndex {
                return $0 != contentRepo.quest.trueAnswer
            }!
            presenter.answer(index: index)
        default: break
        }
    }

    // MARK: - AsyncTestProtocol

    func finishAsyncTest(mode: AsyncTestMode!) {
        if asyncMode != mode {
            return
        }

        switch asyncMode! {
        case .testShowQuest:
            // Is Empty
            // Timer
            // Update Progress

            let progressValid: Int
            if testMode == .arcade {
                progressValid = Percent.calculatePercent(value: testPoint, count: 20)
            } else if testMode == .sprint {
                progressValid = Percent.calculatePercent(value: testPoint, count: contentRepo.ids!.count)
            } else {
                let theme = contentRepo.getTheme(id: testTheme)!
                let point = Point(count: theme.count, arcade: testPoint, marathon: testPoint, sprint: testPoint)
                let calculator = ProgressCalculator(mode: testMode)
                progressValid = calculator!.getRecordPercent(point: point)
            }

            XCTAssertTrue(view.isUpdateProgress)
            XCTAssertEqual(view.progress, progressValid)

            // updateQuestContent
            XCTAssertTrue(view.isUpdateQuestContent)
            XCTAssertNotNil(view.quest)

            // updateAnswerContent
            XCTAssertTrue(view.isUpdateAnswerContent)
            XCTAssertNotNil(view.answers)
        case .testTrueAnswer, .testFinish:
            // TRUE
            // updatePoint
            XCTAssertTrue(view.isUpdatePoint)
            XCTAssertNotNil(view.point)

            // highlightSelectedAnswer
            XCTAssertTrue(view.isHighlightSelectedAnswer)
            XCTAssertTrue(view.isTrueAnswerHighlight)
            XCTAssertTrue(view.isHighlightAnswerTrueForm)
            XCTAssertEqual(view.highlightIndex, view.trueHighlightIndex)

            if asyncMode! == .testFinish {
                // COMMON - continueGame
                // clearAnswerForms
                // blockAnswers
                // -> loadShowOneQuest
            }
        case .testFalseAnswer:
            // FALSE
            // updateCondition
            XCTAssertTrue(view.isUpdateCondition)
            XCTAssertNotNil(view.condition)
            XCTAssertNotNil(view.conditionType)

            // highlightSelectedAnswer
            XCTAssertTrue(view.isHighlightSelectedAnswer)
            XCTAssertFalse(view.isTrueAnswerHighlight)
            XCTAssertTrue(view.isHighlightAnswerFalseForm)
            XCTAssertEqual(view.highlightIndex, view.falseHighlightIndex)

            // showTrueAnswer
            XCTAssertTrue(view.isShowTrueAnswer)
            XCTAssertNotNil(view.showTrueAnswerIndex)
            XCTAssertNotEqual(view.showTrueAnswerIndex, view.highlightIndex)
                // vibrate
                //XCTAssertTrue(view.isVibrate)
        }

        if asyncMode! == .testFinish {
            if view.isFinish ?? false {
                // blockAnswers
                XCTAssertTrue(view.isBlockAnswers)
                XCTAssertTrue(view.isBlocked)
                // finish
                XCTAssertTrue(view.isFinish)
                // extraArgs!
                XCTAssertNotNil(view.endSegueExtraArgs)
                XCTAssertTrue(view.endSegueExtraArgs.isValid())
                XCTAssertEqual(view.endSegueExtraArgs.themeId, testTheme)
                XCTAssertEqual(view.endSegueExtraArgs.oldRecord, testRecord)

                if testMode == .sprint {
                    XCTAssertEqual(view.endSegueExtraArgs.count, Record.sprintRecordMax)
                } else {
                    XCTAssertEqual(view.endSegueExtraArgs.point, contentRepo.ids!.count)
                    XCTAssertEqual(view.endSegueExtraArgs.count, contentRepo.ids!.count)
                }
                XCTAssertTrue(view.endSegueExtraArgs.errorQuestIds!.isEmpty)

                endTest()
            }
        } else {
            endTest()
        }
    }

    private func endTest() {
        expectation.fulfill()
        expectation = nil
        asyncMode = nil
    }
}
