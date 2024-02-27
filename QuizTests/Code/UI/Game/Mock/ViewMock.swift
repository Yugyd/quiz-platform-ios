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

class ViewMock: GameViewProtocol {
    
    var isAnswerBlocked = false
    
    let presenter: GamePresenterTest!
    
    //let uiDelegate: GameViewController!
    
    init(presenter: GamePresenterTest/*, vc: GameViewController*/) {
        self.presenter = presenter
        //self.uiDelegate = vc
        //self.uiDelegate.gamePresenter = presenter.presenter
    }
    
    // MARK: - GameViewProtocol inner members

    // setEmptyStub
    var isEmpty: Bool!
    func setEmptyStub() {
        print("Method: ", #function)
        //uiDelegate.setEmptyStub()
        
        self.isEmpty = true
    }
    
    // finish
    var isFinish: Bool!
    var endSegueExtraArgs: EndSequeExtraArgs!
    func finish(sequeExtraArgs: EndSequeExtraArgs?) {
        print("Method: ", #function)
        //uiDelegate.finish(sequeExtraArgs: sequeExtraArgs)
        
        self.isFinish = true
        self.endSegueExtraArgs = sequeExtraArgs
        
        presenter.finishAsyncTest(mode: .testFinish)
    }
    
    // MARK: - BarGameView

    // setupConditionView
    var isSetupConditionView: Bool!
    var conditionType: GameProcess.ConditionType! // + updateCondition
    func setupConditionView(type: GameProcess.ConditionType) {
        print("Method: ", #function)
        //uiDelegate.setupConditionView(conditionType: conditionType)
        
        switch type {
        case .life:
            switch presenter.testMode {
            case .arcade, .marathon, .error:
                isSetupConditionView = true
            default:
                isSetupConditionView = false
            }
        case .time:
            if presenter.testMode == .sprint {
                isSetupConditionView = true
            } else {
                isSetupConditionView = false
            }
        }
        
        self.conditionType = type
    }
    
    // updatePoint
    var isUpdatePoint: Bool!
    var point: String! = nil
    func updatePoint(value: Int) {
        print("Method: ", #function)
        //uiDelegate.updatePoint(value: value)
        
        self.point = String(value)
        self.isUpdatePoint = true
    }
    
    var isUpdateCondition: Bool!
    var condition: Int! = nil
    func updateCondition(type: GameProcess.ConditionType, value: Int) {
        print("Method: ", #function)
        //uiDelegate.updateCondition(conditionType: conditionType, value: value)
        
        switch type {
        case .life:
            switch presenter.testMode {
            case .arcade, .marathon, .error:
                self.isUpdateCondition = true
            default:
                self.isUpdateCondition = false
            }
        case .time:
            if presenter.testMode == .sprint {
                self.isUpdateCondition = true
            } else {
                self.isUpdateCondition = false
            }
        }
        
        self.conditionType = type
        self.condition = value
    }
    
    // updateProgress
    var isUpdateProgress: Bool!
    var progress: Int! = nil
    func updateProgress(value: Int) {
        print("Method: ", #function)
        //uiDelegate.updateProgress(value: value)
        
        self.isUpdateProgress = true
        self.progress = value
    }
    
    // MARK: - ContentGameView
    
    // updateQuestContent
    var isUpdateQuestContent: Bool!
    var quest: String!
    func updateQuestContent(quest: String) {
        print("Method: ", #function)
        //uiDelegate.updateQuestContent(quest: quest)
        
        if !(quest.isEmpty) {
            self.isUpdateQuestContent = true
        } else {
            self.isUpdateQuestContent = false
        }
        self.quest = quest
        
        presenter.hockLoadQuestEnd()
    }
    
    // MARK: - AnswerControlGameView
    
    // updateAnswerContent
    var isUpdateAnswerContent: Bool!
    var answers: [String]!
    func updateAnswerContent(answers: [String]) {
        print("Method: ", #function)
        //uiDelegate.updateAnswerContent(answers: answers)
        
        if answers.count == 4 {
            self.isUpdateAnswerContent = true
        } else {
            self.isUpdateAnswerContent = false
        }
        self.answers = answers
        
        presenter.finishAsyncTest(mode: .testShowQuest)
        presenter.hookTestAnswer()
    }
    
    func setupViews() {
        
    }
    
    // highlightSelectedAnswer
    var isHighlightSelectedAnswer: Bool!
    var highlightIndex: Int! // + highlightAnswerTrueForm, highlightAnswerFalseForm
    var isTrueAnswerHighlight: Bool!
    func highlightSelectedAnswer(index: Int, isTrueAnswer isHighlight: Bool) {
        print("Method: ", #function)
        //uiDelegate.highlightSelectedAnswer(index: index, isTrueAnswer: isHighlight)
        
        self.isHighlightSelectedAnswer = true
        self.highlightIndex = index
        self.isTrueAnswerHighlight = isHighlight
        
        if isHighlight {
            highlightAnswerTrueForm(index: index)
        } else {
            highlightAnswerFalseForm(index: index)
        }
    }
    
    // highlightAnswerTrueForm
    var isHighlightAnswerTrueForm: Bool!
    var trueHighlightIndex: Int!
    func highlightAnswerTrueForm(index: Int) {
        print("Method: ", #function)
        //uiDelegate.highlightAnswerTrueForm(index: index)
        
        self.isHighlightAnswerTrueForm = true
        self.trueHighlightIndex = index
        
        presenter.finishAsyncTest(mode: .testTrueAnswer)
        presenter.finishAsyncTest(mode: .testFinish)
    }
    
    // highlightAnswerFalseForm
    var isHighlightAnswerFalseForm: Bool!
    var falseHighlightIndex: Int!
    func highlightAnswerFalseForm(index: Int) {
        print("Method: ", #function)
        //uiDelegate.highlightAnswerFalseForm(index: index)
        
        self.isHighlightAnswerFalseForm = true
        self.falseHighlightIndex = index
    }
    
    // showTrueAnswer
    var isShowTrueAnswer: Bool!
    var showTrueAnswerIndex: Int!
    func showTrueAnswer(index: Int) {
        print("Method: ", #function)
        //uiDelegate.showTrueAnswer(index: index)
        
        self.isShowTrueAnswer = true
        self.showTrueAnswerIndex = index
        
        presenter.finishAsyncTest(mode: .testFalseAnswer)
    }
    
    // clearAnswerForms
    var isClearAnswerForms: Bool!
    func clearAnswerForms() {
        print("Method: ", #function)
        //uiDelegate.clearAnswerForms()
        
        self.isClearAnswerForms = true
    }
    
    // blockAnswers
    var isBlockAnswers: Bool!
    var isBlocked: Bool!
    func blockAnswers(isBlocked: Bool) {
        print("Method: ", #function)
        //uiDelegate.blockAnswers(isBlocked: isBlocked)
        
        self.isBlockAnswers = true
        self.isBlocked = isBlocked
    }
    
    var isVibrate: Bool!
    func vibrate() {
        print("Method: ", #function)
        //uiDelegate.vibrate()
        
        self.isVibrate = true
    }
}
