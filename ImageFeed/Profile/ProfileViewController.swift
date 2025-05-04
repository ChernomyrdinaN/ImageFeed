//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Класс ViewController Профиля
//
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageDownloadTask: URLSessionTask?
    
    // UI Elements
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        updateProfile()
        loadInitialAvatar()
    }
    
    private func loadInitialAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL) else {
            return
        }
        downloadImage(from: url)
    }
    
    private func updateProfile() {
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        } else {
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
    
    // MARK: - Image Loading (using generic approach)
    private func downloadImage(from url: URL) {
        profileImage.image = UIImage(named: "profileImage")
        imageDownloadTask?.cancel()
        
        imageDownloadTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Invalid image data")
                return
            }
            
            DispatchQueue.main.async {
                self.profileImage.image = image
            }
        }
        
        imageDownloadTask?.resume()
    }
    
    // MARK: - Observers
    private func setupObservers() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let urlString = notification.userInfo?["URL"] as? String,
                  let url = URL(string: urlString) else { return }
            
            self.downloadImage(from: url)
        }
    }
}
