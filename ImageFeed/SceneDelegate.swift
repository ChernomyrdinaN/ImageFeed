//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.03.2025.
//

import UIKit

// MARK: - SceneDelegate
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    static var shared: SceneDelegate {
        return UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
    }
    
    var window: UIWindow?
    
    // MARK: - Lifecycle
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: scene)
        showSplashScreen()
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    private func showSplashScreen() {
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkAuthState()
        }
    }
    
    private func checkAuthState() {
        let hasToken = OAuth2TokenStorage.shared.token != nil
        
        if hasToken {
            showMainInterface()
        } else {
            showAuthViewController()
        }
    }
    
    private func showMainInterface() {
        let tabBarVC = TabBarController()
        window?.rootViewController = tabBarVC
    }
    
    private func showAuthViewController() {
        let authVC = AuthViewController()
        let navController = UINavigationController(rootViewController: authVC)
        window?.rootViewController = navController
    }
}

// MARK: - WebViewViewControllerDelegate
extension SceneDelegate: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showMainInterface()
                case .failure(let error):
                    AlertService.showErrorAlert(on: vc, message: "Не удалось войти в систему")
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

        func sceneDidDisconnect(_ scene: UIScene) {
            // Called as the scene is being released by the system.
            // This occurs shortly after the scene enters the background, or when its session is discarded.
            // Release any resources associated with this scene that can be re-created the next time the scene connects.
            // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        }
        
        func sceneDidBecomeActive(_ scene: UIScene) {
            // Called when the scene has moved from an inactive state to an active state.
            // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        }
        
        func sceneWillResignActive(_ scene: UIScene) {
            // Called when the scene will move from an active state to an inactive state.
            // This may occur due to temporary interruptions (ex. an incoming phone call).
        }
        
        func sceneWillEnterForeground(_ scene: UIScene) {
            // Called as the scene transitions from the background to the foreground.
            // Use this method to undo the changes made on entering the background.
        }
        
        func sceneDidEnterBackground(_ scene: UIScene) {
            // Called as the scene transitions from the foreground to the background.
            // Use this method to save data, release shared resources, and store enough scene-specific state information
            // to restore the scene back to its current state.
        }
    


