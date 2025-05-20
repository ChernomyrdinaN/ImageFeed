//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//  Контроллер запуска, управляющий процессом аутентификации и загрузки данных пользователя

import UIKit
import ProgressHUD

// MARK: - SplashViewController
final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private var isFetchingProfile = false
    
    private lazy var splashScreenLogo: UIImageView = {
        let image = UIImage(named: "LaunchLogo") ?? UIImage(systemName: "power")!
        let logo = UIImageView(image: image)
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        checkAuthStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = Colors.black
    }
    
    private func setupLogo() {
        view.addSubview(splashScreenLogo)
        NSLayoutConstraint.activate([
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Auth Flow
    private func checkAuthStatus() {
        if let token = OAuth2TokenStorage.shared.token {
            print("[SplashViewController.checkAuthStatus]: Токен найден - переход на главный экран")
            fetchProfile(token: token)
        } else {
            print("[SplashViewController.checkAuthStatus]: Токен не найден - переход на авторизацию")
            showAuthViewController()
        }
    }
    
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        if let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController {
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true) {
                print("[SplashViewController] AuthViewController показан")
            }
        } else {
            print("[SplashViewController] Ошибка: не удалось создать AuthViewController")
        }
    }
    
    // MARK: - Navigation
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first
        else {
            print("[SplashViewController.switchToTabBarController]: Error - Не удалось получить окно приложения")
            return
        }
        print("[SplashViewController.switchToTabBarController]: Успех - окно приложения получено")
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        AlertService.showErrorAlert(
            on: self,
            message: message
        )
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchAuthTokenAndProfile(with: code)
    }
    
    // MARK: - Data Loading
    private func fetchAuthTokenAndProfile(with code: String) {
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
            print("[SplashViewController.fetchAuthTokenAndProfile]: Warning - Токен уже существует")
            return
        }
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.show()
            
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    OAuth2TokenStorage.shared.token = token
                    self?.fetchProfile(token: token)
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure(let error):
                    print("[SplashViewController.fetchAuthTokenAndProfile]: Error \(error) - code: \(code.prefix(4))...")
                    self?.showErrorAlert(message: "Ошибка авторизации")
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func fetchProfile(token: String) {
        guard !isFetchingProfile else { return }
        print("[SplashViewController.fetchProfile]: Статус - isFetchingProfile: \(isFetchingProfile)")
        
        isFetchingProfile = true
        
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isFetchingProfile = false
                
                switch result {
                case .success(let profile):
                    print("[SplashViewController.fetchProfile]: Успех - профиль загружен")
                    self?.fetchProfileImage(username: profile.username)
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("[SplashViewController.fetchProfile]: Error \(error) - token: \(token.prefix(8))...")
                    self?.showErrorAlert(message: "Ошибка загрузки профиля")
                    self?.switchToTabBarController()
                }
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("[SplashViewController.fetchProfileImage]: Успех - username: \(username)")
                case .failure(let error):
                    print("[SplashViewController.fetchProfileImage]: \(error) - username: \(username)")
                }
            }
        }
    }
}
