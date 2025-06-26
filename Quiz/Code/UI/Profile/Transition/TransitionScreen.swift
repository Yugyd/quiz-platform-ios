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

struct TransitionScreen: View {
    
    var onBack: () -> Void
    
    @ObservedObject var viewModel: TransitionViewModel
    
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
                TransitionContent(
                    items: viewModel.items,
                    onItemClicked: { transition in
                        viewModel.onAction(action: TransactionAction.onTransitionClicked(transition))
                    }
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

#Preview {
    let lineSepartorFormatter: LineSeparatorFormatter = IocContainer.app.resolve()
    
    TransitionScreen(
        onBack: {},
        viewModel: TransitionViewModel(
            transitionInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
    )
}
