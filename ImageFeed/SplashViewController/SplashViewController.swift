//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//  Класс ViewController сплэша, который проверяет авторизацию и навигирует пользователя

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    // MARK: - Constants
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    // MARK: - Services
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    
    // MARK: - UI Elements
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
    
    // MARK: - View Setup
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
        if OAuth2TokenStorage.shared.token != nil {
            print("Токен есть - переходим на главный экран")
            switchToTabBarController()
        } else {
            print("Токена нет - переходим на авторизацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    // MARK: - Error Handling
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

// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchAuthTokenAndProfile(with: code)
    }
    
    func checkAuthAndFetchProfile() {
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        }
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
                    print("[SplashViewController.fetchAuthToken]: \(error) - code: \(code)")
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
                    self?.fetchProfileImage(username: profile.username)
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("[SplashViewController.fetchProfile]: \(error) - token: \(token.prefix(8))...")
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
                    print("[SplashViewController.fetchProfileImage]: Success - username: \(username)")
                case .failure(let error):
                    print("[SplashViewController.fetchProfileImage]: \(error) - username: \(username)")
                }
            }
        }
    }
}
