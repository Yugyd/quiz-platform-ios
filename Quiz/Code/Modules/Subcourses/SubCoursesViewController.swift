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

private let segueSubCoursesToCourseDetails = "segueSubCoursesToCourseDetails"
private let segueSubCoursesToSubCourses = "segueSubCoursesToSubCourses"

class SubCourseListViewController: UIViewController, SubCoursesViewProtocol {
    
    var sequeExtraCourseIdArg: Int?
    var sequeExtraCourseTitleArg: String?
    var sequeExtraIsHiddenCurrentArg: Bool?

    private var viewModel: SubCourseListViewModel!

    // MARK: - Life Cycle

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
        
        viewModel.onAction(.loadData)
    }
    
    // MARK: - Host Controller Factory

    private func createHostController() -> UIHostingController<SubCourseListScreen> {
        viewModel = SubCourseListViewModel(
            initialArgs: SubCoursesInitialArgs(
                courseId: sequeExtraCourseIdArg!,
                courseTitle: sequeExtraCourseTitleArg!,
                isHideContinueBanner: sequeExtraIsHiddenCurrentArg!
            ),
            courseInteractor: IocContainer.app.resolve(),
            logger: IocContainer.app.resolve()
        )
        
        let view = SubCourseListScreen(
            viewModel: viewModel,
            onBack: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onNavigateToSubCourse: { [weak self] subCourseArgs in
                self?.performSegue(
                    withIdentifier: segueSubCoursesToSubCourses,
                    sender: SubcoursesSenderArgs(
                        id: subCourseArgs.courseId,
                        title: subCourseArgs.courseTitle,
                        isHiddenCurrentCourse: subCourseArgs.isHideContinueBanner
                    )
                )
            },
            onNavigateToCourseDetails: { [weak self] courseId, courseTitle in
                self?.performSegue(
                    withIdentifier: segueSubCoursesToCourseDetails,
                    sender: CourseDetailsSenderArgs(
                        id: courseId,
                        title: courseTitle
                    )
                )
            }
        )
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinition = segue.destination as? SubCoursesViewProtocol {
            guard let senderArgs = sender as? SubcoursesSenderArgs else {
                return
            }
            
            destinition.sequeExtraCourseIdArg = senderArgs.id
            destinition.sequeExtraCourseTitleArg = senderArgs.title
            destinition.sequeExtraIsHiddenCurrentArg = senderArgs.isHiddenCurrentCourse
        } else if let destinition = segue.destination as? CourseDetailsViewProtocol {
            guard let senderArgs = sender as? CourseDetailsSenderArgs else {
                return
            }
            
            destinition.sequeExtraCourseIdArg = senderArgs.id
            destinition.sequeExtraCourseTitleArg = senderArgs.title
        }
    }
}
