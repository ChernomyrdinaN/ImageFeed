//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//  Класс ViewController сплэша

import UIKit

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthScreen"
    
    private lazy var splashScreenlogo: UIImageView = {
        let image = UIImage(named: "LaunchLogo") ?? UIImage(systemName:"power")!
        let spcl = UIImageView(image: image)
        spcl.translatesAutoresizingMaskIntoConstraints = false
        return spcl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        setSplashScreenlogoView()
    }
    
    private func setSplashScreenlogoView() {
        view.addSubview(splashScreenlogo)
        
        NSLayoutConstraint.activate([splashScreenlogo.centerYAnchor.constraint(equalTo:view.centerYAnchor),splashScreenlogo.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
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
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

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

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) {
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.switchToTabBarController()
                case .failure:
                    // TODO [Sprint 11]
                    break
                }
            }
        }
    }
}
