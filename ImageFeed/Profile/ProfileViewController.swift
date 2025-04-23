//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//  Класс ViewController Профиля

import UIKit

final class ProfileViewController: UIViewController {
    
    private lazy var profileImage: UIImageView = {
        let image = UIImage(named: "profileImage")
        let prfImage = UIImageView(image: image)
        prfImage.layer.cornerRadius = 35
        prfImage.layer.masksToBounds = true
        return prfImage
    }()
    
    private lazy var nameLabel: UILabel = {
        let nmLabel = UILabel()
        nmLabel.text = "Наталья Черномырдина"
        nmLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nmLabel.textColor = Colors.white
        
        return nmLabel
    }()
    
    private lazy var loginLabel: UILabel = {
        let lgLabel = UILabel()
        lgLabel.text = "@chernomyrdina_nata"
        lgLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lgLabel.textColor = Colors.gray
        lgLabel.translatesAutoresizingMaskIntoConstraints = false
        return lgLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let dscrLabel = UILabel()
        dscrLabel.text = "Hello, world!"
        dscrLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        dscrLabel.textColor = Colors.white
        return dscrLabel
        
    }()
    
    private lazy var logoutButton: UIButton = {
        let lgtImage = UIImage(named: "logout") ?? UIImage(systemName: "power")!
        let lgtButton = UIButton.systemButton(with: lgtImage,target: self,action: nil)
        lgtButton.tintColor = Colors.red
        return lgtButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        addSubviews()
        setUpUI()
    }
    
    private func setUpUI() {
        setUpProfileImageView()
        setUpNameLabel()
        setUpLoginLabel()
        setUpDescriptionLabel()
        setUpLogoutButton()
    }
    
    private func addSubviews() {
        [nameLabel, loginLabel, profileImage, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setUpProfileImageView() {
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)])
        self.profileImage = profileImage
    }
    
    private func setUpNameLabel() {
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor,constant: 8)])
        self.nameLabel = nameLabel
    }
    
    private func setUpLoginLabel() {
        
        NSLayoutConstraint.activate([
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)])
        self.loginLabel = loginLabel
    }
    
    private func setUpDescriptionLabel() {
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor,constant: 8)])
    }
    
    private func setUpLogoutButton () {
        
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)])
    }
    
}
