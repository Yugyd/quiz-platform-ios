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

import SwiftUI

struct TonalButton: View {
    
    let title: Text
    let matchParent: Bool
    let action: () -> Void
    
    init(title: Text, matchParent: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.matchParent = matchParent
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            title
                .font(.headline)
                .foregroundStyle(Color.mdOnSecondaryContainer)
                .frame(maxWidth: matchParent ? .infinity : nil)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: ButtonConstans.largeButtonCornerRadius))
        .controlSize(.large)
        .tint(Color.mdSecondaryContainer)
    }
}

#Preview {
    TonalButton(
        title: Text("Title"),
        action: {}
    )
}
