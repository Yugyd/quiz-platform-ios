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

import UIKit
import SwiftUI

private let segueCourseDetailsToGame = "segueCourseDetailsToGame"
private let segueCourseDetailsToReport = "segueCourseDetailsToReport"

class CourseDetailsViewController: UIViewController, CourseDetailsViewProtocol {
    
    @IBOutlet weak var reportBugBarButtonItem: UIBarButtonItem!
    
    var sequeExtraCourseIdArg: Int?
    var sequeExtraCourseTitleArg: String?
    
    // MARK: - ViewModel
    private var viewModel: CourseDetailsViewModel!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = createHostController()
        let swiftUiView = hostingController.view!
        swiftUiView.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(swiftUiView)
        
        NSLayoutConstraint.activate([
            swiftUiView.topAnchor.constraint(equalTo: view.topAnchor),
            swiftUiView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swiftUiView.leftAnchor.constraint(equalTo: view.leftAnchor),
            swiftUiView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        hostingController.didMove(toParent: self)
        
        navigationItem.title = sequeExtraCourseTitleArg ?? String(localized: "course_list_title", table: appLocalizable)
        
        viewModel.onAction(action: .loadData)
    }
    
    // MARK: - Binding
    
    @IBAction func actionReportAiBug(_ sender: UIBarButtonItem) {
        viewModel.onAction(action: .onReportClicked)
    }
    
    // MARK: - Host
    
    private func createHostController() -> UIHostingController<CourseDetailsScreen> {
        // Initialize ViewModel
        viewModel = CourseDetailsViewModel(
            initialArgs: CourseDetailsInitialArgs(
                courseId: sequeExtraCourseIdArg!,
                courseTitle: sequeExtraCourseTitleArg!
            ),
            featureManager: IocContainer.app.resolve(),
            courseInteractor: IocContainer.app.resolve(),
            aiTasksInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        // Build the SwiftUI View
        let view = CourseDetailsScreen(
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onNavigateToAiTasks: { [weak self] id in
                self?.performSegue(
                    withIdentifier: segueCourseDetailsToGame,
                    sender: CourseDetailsGameSenderArgs(courseId: id)
                )
            },
            onNavigateToExternalReportError: { [weak self] id, body in
                self?.performSegue(
                    withIdentifier: segueCourseDetailsToReport,
                    sender: CourseDetailsReportSenderArgs(
                        courseId: id,
                        courseBody: body
                    )
                )
            },
            viewModel: viewModel
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToCourseDetailsViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinition = segue.destination as? ReportViewProtocol, let sender = sender as? CourseDetailsReportSenderArgs {
            let sequeExtraMetadataArg = """
            --- Technical Info ---
            
            {
              "courseId": \(sender.courseId),
              "courseBody": "\(sender.courseBody)"
            }
            
            --- User Message ---
            
            """
            
            destinition.sequeExtraMetadataArg = sequeExtraMetadataArg
        } else if let destinition = segue.destination as? GameViewController, let sender = sender as? CourseDetailsGameSenderArgs {
            if let destinition = segue.destination as? GameViewController {
                destinition.hidesBottomBarWhenPushed = true
                destinition.sequeExtraArgs = GameSequeExtraArgs.Builder
                    .with(mode: .aiTasks, themeId: sender.courseId)
                    .build()
            }
        }
    }
    
    private struct CourseDetailsReportSenderArgs {
        let courseId: Int
        let courseBody: String
    }
    
    private struct CourseDetailsGameSenderArgs {
        let courseId: Int
    }
}
