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

struct ContentScreen: View {
    @StateObject var viewModel: ContentViewModel = ContentViewModel()
    
    var body: some View {
        if viewModel.isLoading {
            LoadingScreen()
        } else if viewModel.isWarning {
            WarningScreen(
                isRetryButtonEnabled: .constant(false),
                onRetryClicked: nil
            )
        } else if viewModel.items.isEmpty {
            ContentEmptyState(
                onChooseFileClicked: viewModel.onOpenFileClicked,
                onDataFormatClicked: viewModel.onContentFormatClicked
            )
        } else {
            ContentView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentScreen()
}
