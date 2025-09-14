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

class ContentDbMapper {
    
    private let decoder: DecoderProtocol
    private let questFormatter: SymbolFormatter
    
    init(
        decoder: DecoderProtocol,
        questFormatter: SymbolFormatter,
    ) throws {
        self.decoder = decoder
        self.questFormatter = questFormatter
    }
    
    func mapToTheme(_ record: CategoryRecord) -> Theme {
        let p = Point(count: record.count, arcade: 0, marathon: 0, sprint: 0)
        
        return Theme(
            id: Int(record._id ?? 0),
            name: record.name,
            info: record.info,
            image: record.image,
            count: record.count,
            ordinal: record.ordinal,
            point: p
        )
    }
    
    func mapToCategoryRecord(_ theme: Theme) -> CategoryRecord {
        return CategoryRecord(
            _id: theme.id,
            ordinal: theme.ordinal,
            name: theme.name,
            info: theme.info,
            image: theme.image,
            count: theme.count
        )
    }
    
    func mapToQuest(_ record: QuestRecord) -> Quest {
        var wrongs = [String]()
        if let a = record.answer2 { wrongs.append(a) }
        if let a = record.answer3 { wrongs.append(a) }
        if let a = record.answer4 { wrongs.append(a) }
        if let a = record.answer5 { wrongs.append(a) }
        if let a = record.answer6 { wrongs.append(a) }
        if let a = record.answer7 { wrongs.append(a) }
        if let a = record.answer8 { wrongs.append(a) }
        
        var answers = Array(wrongs.shuffled().prefix(3))
        answers.append(record.true_answer)
        let shuffled = answers.shuffled()
        
        let decryptedQuest = questFormatter.format(data: decoder.decrypt(encryptedText: record.quest))
        let decryptedTrue = decoder.decrypt(encryptedText: record.true_answer)
        
        let decryptedAnswers = shuffled.map { decoder.decrypt(encryptedText: $0) }
        
        return Quest(
            id: Int(record._id ?? 0),
            quest: decryptedQuest,
            trueAnswer: decryptedTrue,
            answers: decryptedAnswers,
            complexity: record.complexity,
            category: record.category,
            section: record.section
        )
    }
    
    func mapToQuestRecord(_ quest: Quest) -> QuestRecord {
        return QuestRecord(
            _id: quest.id,
            quest: quest.quest,
            image: nil,
            true_answer: quest.trueAnswer,
            answer2: quest.answers.indices.contains(1) ? quest.answers[1] : nil,
            answer3: quest.answers.indices.contains(2) ? quest.answers[2] : nil,
            answer4: quest.answers.indices.contains(3) ? quest.answers[3] : nil,
            answer5: quest.answers.indices.contains(4) ? quest.answers[4] : nil,
            answer6: quest.answers.indices.contains(5) ? quest.answers[5] : nil,
            answer7: quest.answers.indices.contains(6) ? quest.answers[6] : nil,
            answer8: quest.answers.indices.contains(7) ? quest.answers[7] : nil,
            complexity: quest.complexity,
            category: quest.category,
            section: quest.section,
            type: "simple"
        )
    }
    
    func mapToErrorQuest(_ record: QuestRecord) -> ErrorQuest {
        let q = questFormatter.format(data: self.decoder.decrypt(encryptedText: record.quest))
        let a = decoder.decrypt(encryptedText: record.true_answer)
        return ErrorQuest(id: Int(record._id ?? 0), quest: q, trueAnswer: a)
    }
}
