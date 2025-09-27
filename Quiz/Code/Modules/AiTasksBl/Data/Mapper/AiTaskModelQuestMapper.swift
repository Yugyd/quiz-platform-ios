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

final class AiTaskModelQuestMapper {
   
    static func map(_ aiTask: AiTaskModel) -> Quest {
        // Collect all non-nil, non-empty answers
        var answers: [String] = [aiTask.trueAnswer]
        
        let optionalAnswers = [
            aiTask.answer2,
            aiTask.answer3,
            aiTask.answer4,
            aiTask.answer5,
            aiTask.answer6,
            aiTask.answer7,
            aiTask.answer8
        ]
       
        for ans in optionalAnswers {
            if let ans = ans, !ans.isEmpty {
                answers.append(ans)
            }
        }
        // Shuffle answers for fairness (optional)
        answers.shuffle()

        return Quest(
            id: aiTask.id,
            quest: aiTask.quest,
            trueAnswer: aiTask.trueAnswer,
            answers: answers,
            complexity: aiTask.complexity,
            category: aiTask.category,
            section: aiTask.section,
            type: QuestType.simple
        )
    }
}
