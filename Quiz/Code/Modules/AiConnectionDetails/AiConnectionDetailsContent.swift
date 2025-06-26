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

struct AiConnectionDetailsContent: View {
    let name: String
    let provider: String
    let allProviders: [String]
    let isProviderEnabled: Bool
    let apiKey: String
    let cloudProjectFolder: String
    let isCloudProjectFolderVisible: Bool
    let isSaveButtonEnabled: Bool

    let onKeyInstructionClicked: () -> Void
    let onSaveClicked: () -> Void
    let onNameChanged: (String) -> Void
    let onProviderSelected: (String) -> Void
    let onApiKeyChanged: (String) -> Void
    let onCloudProjectFolderChanged: (String) -> Void

    @State private var providerMenuExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                TwoLineWithActionsElevatedCard(
                    title: String(localized: "ai_connection_details_title", table: appLocalizable),
                    subtitle: String(localized:"ai_connection_details_description", table: appLocalizable),
                    confirm: String(localized:"ai_connection_details_open", table: appLocalizable),
                    cancel: nil,
                    onConfirmClicked: onKeyInstructionClicked,
                    onCancelClicked: nil
                )

                Spacer().frame(height: 16)

                // Name TextField
                HStack {
                    TextField(
                        String(localized: "ai_connection_details_name", table: appLocalizable),
                        text: Binding(
                            get: { name },
                            set: { onNameChanged($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    if !name.isEmpty {
                        Button(action: { onNameChanged("") }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.mdOnSurfaceVariant)
                        }
                    }
                }

                Spacer().frame(height: 16)

                // Provider dropdown using Menu (native SwiftUI)
                Menu {
                    ForEach(allProviders, id: \.self) { option in
                        Button(option) {
                            onProviderSelected(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(provider.isEmpty ? String(localized: "ai_connection_details_provider", table: appLocalizable) : provider)
                            .foregroundColor(provider.isEmpty ? .mdOnSurfaceVariant : .mdOnSurface)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.mdOnSurfaceVariant)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.mdOutlineVariant, lineWidth: 1)
                    )
                }
                .disabled(!isProviderEnabled)

                Spacer().frame(height: 16)

                // API Key TextField
                HStack {
                    TextField(
                        String(localized: "ai_connection_details_api_key", table: appLocalizable),
                        text: Binding(
                            get: { apiKey },
                            set: { onApiKeyChanged($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .foregroundColor(.mdOnSurface)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)

                    Button(action: {
                        onApiKeyChanged("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.mdOnSurfaceVariant)
                    }
                }

                if isCloudProjectFolderVisible {
                    Spacer().frame(height: 16)
                    // Cloud Project Folder
                    HStack {
                        TextField(
                            String(localized: "ai_connection_details_project_folder", table: appLocalizable),
                            text: Binding(
                                get: { cloudProjectFolder },
                                set: { onCloudProjectFolderChanged($0) }
                            )
                        )
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .foregroundColor(.mdOnSurface)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)

                        Button(action: {
                            onCloudProjectFolderChanged("")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.mdOnSurfaceVariant)
                        }
                    }
                }

                Spacer().frame(height: 16)

                HStack {
                    Spacer()
                    PrimaryButton(
                        title: Text("ai_connection_details_action_save", tableName: appLocalizable),
                        action: onSaveClicked
                    )
                    .disabled(!isSaveButtonEnabled)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.mdSurface)
    }
}

#Preview("Disabled State") {
    AiConnectionDetailsContent(
        name: "Disabled Connection",
        provider: "Gemini",
        allProviders: ["OpenAI", "Gemini", "Claude"],
        isProviderEnabled: false,
        apiKey: "test",
        cloudProjectFolder: "test",
        isCloudProjectFolderVisible: true,
        isSaveButtonEnabled: false,
        onKeyInstructionClicked: {},
        onSaveClicked: {},
        onNameChanged: { _ in },
        onProviderSelected: { _ in },
        onApiKeyChanged: { _ in },
        onCloudProjectFolderChanged: { _ in }
    )
    .padding(0)
}
