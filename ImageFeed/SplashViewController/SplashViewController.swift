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
    private let profileService = ProfileService.shared
    // private let storage = OAuth2TokenStorage()
    
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

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchAuthTokenAndProfile(with: code)
    }
    
    func checkAuthAndFetchProfile() {
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        }
        // Если токена нет - ничего не делаем (покажем экран авторизации)
    }
    
    private func fetchAuthTokenAndProfile(with code: String) {
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    OAuth2TokenStorage.shared.token = token
                    self?.fetchProfile(token: token)
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("❌ Token error: \(error.localizedDescription)")
                    self?.showErrorAlert(message: "Ошибка авторизации")
                }
            }
        }
    }
    
    private func fetchProfile(token: String) {
        ProfileService.shared.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let profile):
                    // Запускаем загрузку аватарки (не дожидаясь завершения)
                    self?.fetchProfileImage(username: profile.username)
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("❌ Profile error: \(error.localizedDescription)")
                    // Переходим дальше даже при ошибке, но показываем алерт
                    self?.showErrorAlert(message: "Ошибка загрузки профиля")
                    self?.switchToTabBarController()
                }
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        // Запускаем загрузку аватарки, но не ждём её завершения
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print(
                        "✅ Аватарка успешно загружена"
                    )
                case .failure(let error):
                    print("❌ Ошибка загрузки аватарки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
