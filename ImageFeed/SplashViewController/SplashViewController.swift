//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//  Класс ViewController сплэша, который проверяет авторизацию и навигирует пользователя: на главный экран или экран авторизации

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen" // идентификатор перехода к экрану авторизации
    
    private lazy var splashScreenlogo: UIImageView = {
        let image = UIImage(named: "LaunchLogo") ?? UIImage(systemName:"power")!
        let spcl = UIImageView(image: image)
        spcl.translatesAutoresizingMaskIntoConstraints = false
        return spcl
    }()
    // Проверка авторизации
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        setSplashScreenlogoView()
    }
    
    private func setSplashScreenlogoView() {
        view.addSubview(splashScreenlogo)
        
        NSLayoutConstraint.activate(
            [
                splashScreenlogo.centerYAnchor.constraint(
                    equalTo:view.centerYAnchor
                ),
                splashScreenlogo.centerXAnchor.constraint(
                    equalTo: view.centerXAnchor
                )
            ]
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        checkAuthStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func checkAuthStatus() {
        if OAuth2TokenStorage.shared.token != nil {
            print("Токен есть - переходим на главный экран")
            switchToTabBarController()
        } else {
            print("Токена нет - переходим на авторизацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() { // переход на главный
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // подготовка перехода на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self // находит AuthViewController в UINavigationController и назначает SplashViewController его делегатом
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate { // обработка успешной авторизации
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show() // показываем индикатор
        self.fetchOAuthToken(code) // запускаем запрос токена
    }
    
    private func fetchOAuthToken(_ code: String) {
       // DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in // искуственная задержка перед запуском
            oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
                UIBlockingProgressHUD.dismiss() // скрываем индикатор по завершению запроса
                switch result {
                case .success:
                    self?.switchToTabBarController() // успех, переходим на главный
                case .failure:
                    // TODO [Sprint 11]
                    break
                }
            }
        }
    }
