//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Класс ViewController Профиля

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageDownloadTask: URLSessionTask?
    
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
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            downloadProfileImage(from: url)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                print("Получено уведомление об изменении аватарки")
                guard let self = self,
                      let urlString = notification.userInfo?["URL"] as? String,
                      let url = URL(string: urlString) else {
                    print("Не удалось получить URL из уведомления")
                    return
                }
                print("Загрузка аватарки по URL: \(url)")
                print("Обработка уведомления с URL: \(urlString)")
                self.downloadProfileImage(from: url)
            }
    }
    private func downloadProfileImage(from url: URL) {
        profileImage.image = UIImage(named: "profileImage") // Установка placeholder
        
        imageDownloadTask?.cancel()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data,
                  let image = UIImage(data: data) else {
                print("Некорректные данные изображения")
                return
            }
            
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
        
        imageDownloadTask = task
        task.resume()
    }
    
    
    private func updateProfile() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
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

