//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//
import UIKit

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared //обращение к синглтону
    
    private let ShowWebViewSegueIdentifier = "ShowWebView" // проидентифицируем segue от "Войти" к Web
    
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
        lgnButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside) // нажатие на кнопку "Войти"
        return lgnButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        
        addSubviews()
        setUpAuthScreenlogoView()
        setUploginButtonView()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // устанавливаем, назначаем делегат
           if segue.identifier == "ShowWebView" {
               guard let webViewViewController = segue.destination as? WebViewViewController else {
                   fatalError("Failed to prepare for ShowWebView segue")
               }
               webViewViewController.delegate = self
           }
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
    
    @objc private func buttonTapped() { // обработчик нажатия и перехода от "Войти" к Web
          performSegue(withIdentifier: "ShowWebView", sender: nil)
      }
      
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
                                             
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}



