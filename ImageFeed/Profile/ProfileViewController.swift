//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Сервис отвечает за отображение профиля пользователя

import UIKit
import Kingfisher

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageDownloadTask: URLSessionTask?
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .all  // Растягивает view на весь экран
        extendedLayoutIncludesOpaqueBars = true  // Учитывает скрытые бары
        configureView()
        setupUI()
        loadProfileData()
        setupObservers()
    }
    
    // MARK: - Configuration
    private func configureView() {
        view.backgroundColor = Colors.black
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        profileImage.image = UIImage(named: "profileImage")
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = Colors.white
        
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = Colors.gray
        
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = Colors.white
        
        let logoutImage = UIImage(named: "logout") ?? UIImage(systemName: "power")!
        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = Colors.red
        
        [profileImage, nameLabel, loginLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
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
    
    // MARK: - Data Loading
    private func loadProfileData() {
        print("[ProfileViewController.loadProfileData]: Статус - начало загрузки данных")
        updateProfile()
        loadAvatar()
    }
    
    private func loadAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL) else {
            print("[ProfileViewController.loadAvatar]: Error - URL аватара невалиден")
            return
        }
        print("[ProfileViewController.loadAvatar]: Статус - начало загрузки аватара. URL: \(avatarURL.prefix(20))...")
        setProfileImage(with: url)
    }
    
    private func setProfileImage(with url: URL) {
        print("[ProfileViewController.setProfileImage]: Статус - установка изображения. URL: \(url.absoluteString.prefix(20))...")
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            completionHandler: { result in
                switch result {
                case .success(let value):
                    print("[ProfileViewController.setProfileImage]: Успех - изображение загружено. Источник: \(value.source.url?.absoluteString.prefix(20) ?? "nil")")
                case .failure(let error):
                    print("[ProfileViewController.setProfileImage]: Error \(error.localizedDescription)")
                }
            }
        )
    }
    private func updateProfile() {
        if let profile = profileService.profile {
            print("[ProfileViewController.updateProfile]: Успех - профиль получен. Имя: \(profile.name.prefix(10))...")
            updateProfileDetails(profile: profile)
        } else {
            print("[ProfileViewController.updateProfile]: Warning - используется дефолтный профиль")
            showDefaultProfile()
        }
    }
    
    private func updateProfileDetails(profile: Profile) {
        DispatchQueue.main.async {
            self.nameLabel.text = profile.name
            self.loginLabel.text = profile.loginName
            self.descriptionLabel.text = profile.bio
        }
    }
    
    private func showDefaultProfile() {
        DispatchQueue.main.async {
            self.nameLabel.text = "Ivan Ivanov"
            self.loginLabel.text = "@ivanivanov"
            self.descriptionLabel.text = "Hello, world!"
        }
    }
    
    // MARK: - Observers
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let urlString = notification.userInfo?["URL"] as? String,
                  let url = URL(string: urlString) else {
                print("[ProfileViewController.setupObservers]: Error - невалидные данные нотификации")
                return }
            print("[ProfileViewController.setupObservers]: Статус - получена нотификация. URL: \(urlString.prefix(20))...")
            self.setProfileImage(with: url)
        }
    }
}

