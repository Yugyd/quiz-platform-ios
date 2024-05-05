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

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            List {
                NewFileItem(onOpenFileClicked: {
                    viewModel.onOpenFileClicked()
                }, onContentFormatClicked: {
                    viewModel.onContentFormatClicked()
                })
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 8, bottom: 24, trailing: 8)
                )
                .listRowSeparator(.hidden)
                
                ForEach(viewModel.items, id: \.id) { item in
                    ContentItem(
                        model: item,
                        onItemClicked: { model in
                            viewModel.onItemClicked(model)
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.inset)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentViewModel())
    }
}
