//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 21.04.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
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
        NSLayoutConstraint.activate([
            splashScreenlogo.widthAnchor.constraint(equalToConstant: 75),
            splashScreenlogo.heightAnchor.constraint(equalToConstant: 77.68),
            splashScreenlogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            splashScreenlogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)]
        )
        //self.splashScreenlogo = splashScreenlogo
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
        
        
        private func checkAuthStatus() {
             if let _ = storage.token {
                 print("Токен есть - переходим на главный экран")
                 
             } else {
                 print("Токена нет - переходим на авторизацию")
                 self.performSegue(withIdentifier: self.showAuthenticationScreenSegueIdentifier, sender: nil)
             }
    }
}
