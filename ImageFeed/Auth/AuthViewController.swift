//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//
import UIKit

final class AuthViewController: UIViewController {
    
    private lazy var authScreenlogo: UIImageView = {
        let image = UIImage(named: "auth_screen_logo") ?? UIImage(systemName:"power")!
        let ascl = UIImageView(image: image)
        
        return ascl
    }()
    
    private lazy var loginButton: UIButton = {
        let lgnButton = UIButton(type: .system)
        lgnButton.setTitle("Войти", for: .normal) //
        lgnButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        lgnButton.setTitleColor(Colors.black, for: .normal)
        lgnButton.backgroundColor = Colors.white
        lgnButton.layer.cornerRadius = 16
        lgnButton.layer.masksToBounds = true
        
        return lgnButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        
        addSubviews()
        setUpAuthScreenlogoView()
        setUploginButtonView()
        
    }
    
    private func addSubviews() {
        [authScreenlogo,loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setUpAuthScreenlogoView() {
        
        NSLayoutConstraint.activate([
            authScreenlogo.widthAnchor.constraint(equalToConstant: 60),
            authScreenlogo.heightAnchor.constraint(equalToConstant: 60),
            authScreenlogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            authScreenlogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)]
        )
        self.authScreenlogo = authScreenlogo
    }
    
    private func setUploginButtonView() {
        
        NSLayoutConstraint.activate(
[
            loginButton.widthAnchor.constraint(equalToConstant: 343),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            
            loginButton.topAnchor.constraint(equalTo: authScreenlogo.bottomAnchor,constant: 204),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16)]
        )
        self.loginButton = loginButton
    }
    
    private let ShowWebViewSegueIdentifier = "ShowWebView" // значение идентификатора segue от "Войти" к Web
}
