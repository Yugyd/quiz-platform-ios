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

struct IconWithBackground: View {
    let size: CGFloat
    let icon: String
    
    var body: some View {
        ZStack {
            Image(icon)
                .resizable()
                .foregroundColor(Color.mdOnPrimary)
        }
        .padding(16)
        .frame(
            width: size,
            height: size
        )
        .background(
            RoundedRectangle(cornerRadius: 16.0)
                .fill(Color.mdPrimary)
        )
    }    
}

#Preview {
    IconWithBackground(
        size: 96,
        icon: "ic_file_open"
    )
}
