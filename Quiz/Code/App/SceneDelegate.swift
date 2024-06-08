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

@MainActor class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let contentInteractor: ContentInteractor = IocContainer.app.resolve()
    private let logger: Logger = IocContainer.app.resolve()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        Task {
            do {
                let isContentSelected = try await contentInteractor.isSelected()
                
                if isContentSelected {
                    showMainApp()
                } else {
                    showContent()
                }
            } catch {
                logger.recordError(error: error)
                showMainApp()
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    // Call this function after completing the content process
    func contentDidComplete() {
        showMainApp()
    }
    
    // MARK: Private
    private func showMainApp() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = mainStoryboard.instantiateInitialViewController()
        self.window?.rootViewController = mainViewController
        self.window?.makeKeyAndVisible()
    }
    
    private func showContent() {
        let contentStoryboard = UIStoryboard(name: "Content", bundle: nil)
        let contentViewController = contentStoryboard.instantiateInitialViewController()
        self.window?.rootViewController = contentViewController
        self.window?.makeKeyAndVisible()
    }
}
