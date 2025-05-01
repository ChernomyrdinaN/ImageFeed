//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Класс ViewController Профиля

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared // Использует синглтон ProfileService.shared для доступа к данным профиля.
    
    // UI элементы добавляются на view программно (без Storyboard)
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        setupViews()
        setupConstraints()
        updateProfile()
    }
    
    private func updateProfile() { //Если есть данные в profileService → обновляет UI
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile) // Если нет → показывает заглушку (showDefaultProfile
        } else {
            showDefaultProfile()
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = profile.name
            self?.loginLabel.text = profile.loginName
            self?.descriptionLabel.text = profile.bio
        }
    }
    
    private func showDefaultProfile() {
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = "Ivan Ivanov"
            self?.loginLabel.text = "@ivanivanov"
            self?.descriptionLabel.text = "Hello, world!"
        }
    }
    
    private func setupViews() {
        // Настройка изображения профиля
        profileImage.image = UIImage(named: "profileImage")
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        
        // Настройка имени
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = Colors.white
        
        // Настройка логина
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = Colors.gray
        
        // Настройка описания
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = Colors.white
        
        // Настройка кнопки выхода
        let logoutImage = UIImage(named: "logout") ?? UIImage(systemName: "power")!
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = Colors.red
        
        // Добавление на view
        [profileImage, nameLabel, loginLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Изображение профиля
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            // Кнопка выхода
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            // Имя
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            
            // Логин
            loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            // Описание
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8)
        ])
    }
}

