//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Отвечает за отображение профиля пользователя

import UIKit
import Kingfisher

// MARK: - Profile ViewController
final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Properties
    private var presenter: ProfilePresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ProfileViewController.viewDidLoad]: Статус - инициализация экрана")
        setupUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Configuration
    func configure(_ presenter: ProfilePresenterProtocol) {
        print("[ProfileViewController.configure]: Статус - настройка презентера")
        self.presenter = presenter
        presenter.view = self
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = Colors.black
        
        profileImage.image = UIImage(named: "profileImage")
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = Colors.white
        
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = Colors.gray
        
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = Colors.white
        
        let logoutImage = UIImage(named: "logout") ?? UIImage(systemName: "power")
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = Colors.red
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        [profileImage, nameLabel, loginLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            
            loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
}
// MARK: - Profile ViewController Protocol
extension ProfileViewController: ProfileViewControllerProtocol {
    
    func updateProfileDetails(name: String, login: String, bio: String?) {
        print("[ProfileViewController.updateProfileDetails]: Обновление данных: \(name.prefix(10))...")
        nameLabel.text = name
        loginLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        print("[ProfileViewController.updateAvatar]: Обновление аватара: \(url.absoluteString.prefix(20))...")
        profileImage.kf.setImage(with: url)
    }
    
    func showDefaultProfile() {
        print("[ProfileViewController.showDefaultProfile]: Показ дефолтного профиля")
        nameLabel.text = "Ivan Ivanov"
        loginLabel.text = "@ivanivanov"
        descriptionLabel.text = "Hello, world!"
    }
    
    func showLogoutConfirmation(completion: @escaping () -> Void) {
        AlertService.showConfirmationAlert(
            on: self,
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            confirmHandler: completion
        )
    }
    
    func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = SplashViewController()
        })
    }
    
    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        presenter?.didTapLogout()
    }
}
