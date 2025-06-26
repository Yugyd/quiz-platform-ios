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

struct ProgressPageScreen: View {
    
    var onBack: () -> Void
        
    @ObservedObject var viewModel: ProgressPageViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingScreen()
            } else if viewModel.isWarning {
                WarningScreen(
                    isRetryButtonEnabled: .constant(false),
                    onRetryClicked: nil
                )
            } else {
                ProgressListView(
                    header: viewModel.header,
                    items: viewModel.items,
                    onItemClicked: { _ in }
                )
            }
        }
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .back:
                onBack()
            case .none:
                break
            }
            
            if navigationState != nil {
                viewModel.onAction(action: .onNavigationHandled)
            }
        }
    }
}

private class MockProgressUpdateCallback: ProgressUpdateCallback {
    func update() {}
}

#Preview {
    ProgressPageScreen(
        onBack: {},
        viewModel: ProgressPageViewModel(
            contentRepository: IocContainer.app.resolve(),
            userRepository: IocContainer.app.resolve(),
            themeId: 1,
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve(),
            updateCalback: MockProgressUpdateCallback()
        )
    )
}
