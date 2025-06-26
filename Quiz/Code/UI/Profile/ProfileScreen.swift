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

import Foundation
import SwiftUI

struct ProfileScreen: View {
    
    let onNavigateToProOnboarding: () -> Void
    let onNavigateToTransition: () -> Void
    let onNavigateToAppStore: () -> Void
    let onNavigateToShare: () -> Void
    let onNavigateToOtherApps: () -> Void
    let onNavigateToExternalReportError: () -> Void
    let onNavigateToPrivacyPolicy: () -> Void
    let onNavigateToContents: () -> Void
    let onNavigateToExternalPlatformReportError: () -> Void
    let onNavigateToExternalPlatformRate: () -> Void
    let onNavigateToTelegramChannel: () -> Void
    let onNavigateToAiConnection: (String?) -> Void

    @ObservedObject var viewModel: ProfileViewModel
    
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
                ProfileListContent(
                    items: viewModel.items,
                    contentTitle: viewModel.contentTitle ?? "",
                    isSorting: viewModel.isSorting,
                    isVibration: viewModel.isVibration,
                    transition: viewModel.transition,
                    versionTitle: viewModel.contentMode?.titleName ?? "",
                    aiEnabled: viewModel.isAiEnabled,
                    aiConnection: viewModel.aiConnection,
                    onItemClicked: { item in
                        viewModel.onAction(action: .onProfileClicked(item: item))
                    },
                    onItemChecked: { item, isChecked in
                        viewModel.onAction(action: .onProfileItemChecked(item: item, isChecked: isChecked))
                    },
                    onRatePlatformClicked: {
                        viewModel.onAction(action: .onRatePlatformClicked)
                    },
                    onReportBugPlatformClicked: {
                        viewModel.onAction(action: .onReportBugPlatformClicked)
                    }
                )
            }
        }
        .onChange(of: viewModel.navigationState) { navigationState in
            switch navigationState {
            case .navigateToProOnboarding:
                onNavigateToProOnboarding()
            case .navigateToTransition:
                onNavigateToTransition()
            case .navigateToAppStore:
                onNavigateToAppStore()
            case .navigateToShare:
                onNavigateToShare()
            case .navigateToOtherApps:
                onNavigateToOtherApps()
            case .navigateToExternalReportError:
                onNavigateToExternalReportError()
            case .navigateToPrivacyPolicy:
                onNavigateToPrivacyPolicy()
            case .navigateToContents:
                onNavigateToContents()
            case .navigateToExternalPlatformReportError:
                onNavigateToExternalPlatformReportError()
            case .navigateToExternalPlatformRate:
                onNavigateToExternalPlatformRate()
            case .navigateToTelegramChannel:
                onNavigateToTelegramChannel()
            case .navigateToAiConnection(let id):
                onNavigateToAiConnection(id)
            case .none:
                break
            }
            
            if navigationState != .none {
                viewModel.onAction(action: .onNavigationHandled)
            }
        }
    }
}

#Preview {
    let userPreferances: UserPreferences = IocContainer.app.resolve()
    ProfileScreen(
        onNavigateToProOnboarding: {},
        onNavigateToTransition: {},
        onNavigateToAppStore: {},
        onNavigateToShare: {},
        onNavigateToOtherApps: {},
        onNavigateToExternalReportError: {},
        onNavigateToPrivacyPolicy: {},
        onNavigateToContents: {},
        onNavigateToExternalPlatformReportError: {},
        onNavigateToExternalPlatformRate: {},
        onNavigateToTelegramChannel: {},
        onNavigateToAiConnection: {_ in},
        viewModel: ProfileViewModel(
            preferences: userPreferances,
            iapHelper: IocContainer.app.resolve(),
            profileInteractor: IocContainer.app.resolve(),
            contentInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve(),
            aiConnectionClient: IocContainer.app.resolve()
        )
    )
}
