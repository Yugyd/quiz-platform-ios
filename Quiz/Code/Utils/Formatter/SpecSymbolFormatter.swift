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

class SpecSymbolFormatter: SymbolFormatter {
    static let commonTextSymbol = "&"
    static let separatorTextSymbol = "#"

    func format(data: String) -> String {
        guard !data.isEmpty else {
            return data
        }

        var result: String = data
        if result.contains(SpecSymbolFormatter.commonTextSymbol) {
            result = result.replacingOccurrences(of: SpecSymbolFormatter.commonTextSymbol, with: "")
        }

        if result.contains(SpecSymbolFormatter.separatorTextSymbol) {
            result = result.replacingOccurrences(of: SpecSymbolFormatter.separatorTextSymbol, with: "\n")
        }

        return result
    }
}
