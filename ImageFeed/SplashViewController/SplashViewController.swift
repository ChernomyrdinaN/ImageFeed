//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//  Сервис контролирует навигацию, управлђет процессом аутентификации,получает профиль пользователя и его аватар через ProfileService и ProfileImageService

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
   // private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    private var isFetchingProfile = false
    
    private lazy var splashScreenLogo: UIImageView = {
        let image = UIImage(named: "LaunchLogo") ?? UIImage(systemName: "power")!
        let logo = UIImageView(image: image)
        logo.translatesAutoresizingMaskIntoConstraints = false
        return logo
    }()
    
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
    
    private func checkAuthStatus() {
        if let token = OAuth2TokenStorage.shared.token {
            print("[SplashViewController.checkAuthStatus]: Токен найден - переход на главный экран")
            fetchProfile(token: token)
        } else {
            print("[SplashViewController.checkAuthStatus]: Токен не найден - переход на авторизацию")
            //performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            showAuthViewController()
        }
    }
    
    
    private func showAuthViewController() {
        
        // Создаем AuthViewController из storyboard
              let storyboard = UIStoryboard(name: "Main", bundle: .main)
              guard let authViewController = storyboard.instantiateViewController(
                  withIdentifier: "AuthViewController"
              ) as? AuthViewController else {
                  fatalError("Failed to instantiate AuthViewController from storyboard")
              }
        
        
          //let authViewController = AuthViewController() // Создаем экземпляр AuthViewController
           authViewController.delegate = self // Устанавливаем себя делегатом
           authViewController.modalPresentationStyle = .fullScreen // Устанавливаем полный экран
           
           // Презентуем модально
           present(authViewController, animated: true) {
           print("[SplashViewController.showAuthViewController]: AuthViewController успешно презентован")
           }
       }
    
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
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка", // макет!!
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        print("[SplashViewController.showErrorAlert]: Показан алерт с сообщением: \(message)")
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchAuthTokenAndProfile(with: code)
    }
    
    private func fetchAuthTokenAndProfile(with code: String) {
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
            print("[SplashViewController.fetchAuthTokenAndProfile]: Warning - Токен уже существует")
            return
        }
        
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.show()
            
            DispatchQueue.main.async {
               // UIBlockingProgressHUD.dismiss()
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
        guard !isFetchingProfile else { return } //если НЕ выполняется загрузка
        print("[SplashViewController.fetchProfile]: Статус - isFetchingProfile: \(isFetchingProfile)")
        
        isFetchingProfile = true //если загрузка уже идёт, метод завершается
        
        
        
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
          
                self?.isFetchingProfile = false //сбрасывает флаг, разрешая новые запросы
                
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


