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

struct ProfileItemView: View {
   
    let model: ProfileItem
    let contentTitle: String
    let isSorting: Bool
    let isVibration: Bool
    let transition: String
    let versionTitle: String
    
    let aiEnabled: Bool
    let aiConnection: String?
    
    let onItemClicked: (ProfileItem) -> Void
    let onItemChecked: (ProfileItem, Bool) -> Void
    let onRatePlatformClicked: () -> Void
    let onReportBugPlatformClicked: () -> Void

    var body: some View {
        switch model.row {
        case let header as HeaderProfileRow:
            HeaderProfileItem(model: header, versionTitle: versionTitle)

        case let section as SectionProfileRow:
            SectionProfileItem(title: section.title)

        case let select as TextProfileRow:
            SelectProfileItem(
                model: select,
                onItemClicked: {
                    onItemClicked(self.model)
                }
            )

        case let value as ValueProfileRow:
            let modelValue: String = {
                switch model.id {
                case .selectContent:
                    return contentTitle
                case .transition:
                    return transition
                case .aiConnection:
                    return aiConnection ?? ""
                default:
                    return ""
                }
            }()
            
            ValueProfileItem(
                model: value,
                modelValue: modelValue,
                onItemClicked: {
                    onItemClicked(self.model)
                }
            )

        case let toggle as SwitchProfileRow:
            let modelValue: Bool = {
                switch model.id {
                case .sortQuest:
                    return isSorting
                case .vibration:
                    return isVibration
                case .aiSwitcher:
                    return aiEnabled
                default:
                    return false
                }
            }()
            
            SwitchProfileItem(
                model: toggle,
                isChecked: modelValue,
                onItemChecked: { isChecked in
                    onItemChecked(self.model, isChecked)
                }
            )

        case let social as TwoTextProfileRow:
            TwoTextProfileItem(
                model: social,
                onItemClicked: {
                    onItemClicked(self.model)
                }
            )

        case _ as OpenSourceAppProfileRow:
            OpenSourceProfileItem(
                onRatePlatformClicked: onRatePlatformClicked,
                onReportBugPlatformClicked: onReportBugPlatformClicked
            )
            .padding()

        default:
            EmptyView()
        }
    }
}

struct HeaderProfileItem: View {
    
    let model: HeaderProfileRow
    let versionTitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(model.appIcon)
                .resizable()
                .frame(width: 96, height: 96)
                .cornerRadius(16)
            
            Text(model.appName)
                .font(.title2)
                .foregroundColor(.mdOnSurface)
                .multilineTextAlignment(.center)
            
            Text(versionTitle)
                .font(.body)
                .foregroundColor(.mdPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.mdSurface)
    }
}

struct SectionProfileItem: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            
            Text(title)
                .font(.title3)
                .foregroundColor(.mdPrimary)
                .padding()
        }
        .padding(0)
        .background(Color.mdSurface)
    }
}

struct SelectProfileItem: View {
    
    let model: TextProfileRow
    let onItemClicked: () -> Void
    
    var body: some View {
        Button(action: { onItemClicked() }) {
            HStack {
                Text(model.title)
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                
                Spacer()
            }
            .padding()
            .background(Color.mdSurface)
        }
    }
}

struct ValueProfileItem: View {
    
    let model: ValueProfileRow
    let modelValue: String
    let onItemClicked: () -> Void
    
    var body: some View {
        Button(action: { onItemClicked() }) {
            HStack {
                Text(model.title)
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                
                Spacer()
                
                Text(modelValue)
                    .font(.caption)
                    .foregroundColor(.mdPrimary)
            }
            .padding()
            .background(Color.mdSurface)
        }
    }
}

struct SwitchProfileItem: View {
    
    let model: SwitchProfileRow
    let isChecked: Bool
    let onItemChecked: (Bool) -> Void
    
    var body: some View {
        HStack {
            Text(model.title)
                .font(.body)
                .foregroundColor(.mdOnSurface)
            
            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { isChecked },
                    set: { onItemChecked($0)
                    }
                )
            )
        }
        .padding()
        .background(Color.mdSurface)
    }
}

struct TwoTextProfileItem: View {
    
    let model: TwoTextProfileRow
    let onItemClicked: () -> Void
    
    var body: some View {
        Button(action: { onItemClicked() }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(model.title)
                        .font(.body)
                        .foregroundColor(.mdOnSurface)

                    Text(model.subtitle)
                        .font(.footnote)
                        .foregroundColor(.mdOnSurfaceVariant)
                }
                Spacer()
                
                Image(
                    systemName: "chevron.right"
                )
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.mdOnSurfaceVariant)
            }
            .padding()
            .background(Color.mdSurface)
        }
    }
}

struct HeaderProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderProfileItem(
            model: HeaderProfileRow(
                appIcon: "icon_app",
                appName: "Quiz App"
            ),
            versionTitle: "v1.0.0"
        )
        .previewLayout(.sizeThatFits)
        .background(Color.mdBackground)
    }
}

struct SectionProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        SectionProfileItem(title: "Settings")
            .previewLayout(.sizeThatFits)
            .background(Color.mdBackground)
    }
}

struct SelectProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        SelectProfileItem(
            model: TextProfileRow(title: "Choose Theme"),
            onItemClicked: {}
        )
        .previewLayout(.sizeThatFits)
        .background(Color.mdBackground)
    }
}

struct ValueProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        ValueProfileItem(
            model: ValueProfileRow(
                title: "Text Size",
            ),
            modelValue: "Test",
            onItemClicked: {},
        )
        .previewLayout(.sizeThatFits)
        .background(Color.mdBackground)
    }
}

struct SwitchProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        SwitchProfileItem(
            model: SwitchProfileRow(
                title: "Enable Vibration",
            ),
            isChecked: true,
            onItemChecked: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .background(Color.mdBackground)
    }
}

struct TwoTextProfileItemView_Previews: PreviewProvider {
    static var previews: some View {
        TwoTextProfileItem(
            model: TwoTextProfileRow(
                title: "Join Telegram",
                subtitle: "Tap to join our community"
            ),
            onItemClicked: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.mdSurface)
    }
}
