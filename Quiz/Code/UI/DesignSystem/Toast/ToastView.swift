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

struct ToastView: View {
    
    @Binding var message: String
    let onDismissRequest: () -> Void
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.mdInverseSurfaceVariant)
            .foregroundColor(Color.mdInverseOnSurfaceVariant)
            .cornerRadius(16)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + ToastConstans.toastLongDuration,
                    execute: {
                        onDismissRequest()
                    }
                )
            }
    }
}

#Preview {
    ToastView(
        message: .constant("Title"),
        onDismissRequest: {}
    )
}
