//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    
    // ИСПРАВЛЕНО: Убрана избыточная перезапись свойства в setUp методах
    private lazy var authScreenlogo: UIImageView = {
        let image = UIImage(named: "auth_screen_logo") ?? UIImage(systemName:"power")!
        let ascl = UIImageView(image: image)
        return ascl
    }()
    
    private lazy var loginButton: UIButton = {
        let lgnButton = UIButton(type: .system)
        lgnButton.setTitle("Войти", for: .normal)
        lgnButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        lgnButton.setTitleColor(Colors.black, for: .normal)
        lgnButton.backgroundColor = Colors.white
        lgnButton.layer.cornerRadius = 16
        lgnButton.layer.masksToBounds = true
        lgnButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView" {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                print("DEBUG: Failed to cast destination for ShowWebView segue")
                return
            }
            webViewViewController.delegate = self
        }
    }
    
    private func addSubviews() {
        [authScreenlogo, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setUpAuthScreenlogoView() {
        NSLayoutConstraint.activate([
            authScreenlogo.widthAnchor.constraint(equalToConstant: 60),
            authScreenlogo.heightAnchor.constraint(equalToConstant: 60),
            authScreenlogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            authScreenlogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func setUploginButtonView() {
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalToConstant: 343),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.topAnchor.constraint(equalTo: authScreenlogo.bottomAnchor, constant: 204),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func buttonTapped() {
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
        UIBlockingProgressHUD.show()
        
        // ИСПРАВЛЕНО: Обновленная проверка с использованием isFetching
        if OAuth2Service.shared.isFetching {
            UIBlockingProgressHUD.dismiss()
            print("Auth request already in progress")
            return
        }
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            DispatchQueue.main.async {
                switch result {
                case .success:
                    vc.dismiss(animated: true) {
                        self?.delegate?.authViewController(self!, didAuthenticateWithCode: code)
                    }
                case .failure(let error):
                    print("[AuthViewController] Auth error: \(error.localizedDescription)")
                    let alert = UIAlertController(
                        title: "Что-то пошло не так",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    vc.present(alert, animated: true)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
