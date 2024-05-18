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
import UIKit
import SwiftUI

class OpenSourceViewCell: UITableViewCell, OpenSourceViewCellProtocol {
    
    private var hostingController: UIHostingController<OpenSourceProfileItem>?
    
    func updateData(
        onRatePlatformClicked: @escaping () -> Void,
        onReportBugPlatformClicked: @escaping () -> Void
    ) {
        let view = OpenSourceProfileItem(
            onRatePlatformClicked: onRatePlatformClicked,
            onReportBugPlatformClicked: onReportBugPlatformClicked
        )
        
        if hostingController == nil {
            hostingController = UIHostingController(rootView: view)
            guard let hostingController = hostingController else { return }
            
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear // Ensure the hosting view's background is clear

            contentView.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate(
                [
                    hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                    hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
                    hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                    hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
                ]
            )
        } else {
            hostingController?.rootView = view
        }
    }
}
