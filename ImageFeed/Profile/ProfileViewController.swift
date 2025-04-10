//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//
import UIKit


final class ProfileViewController: UIViewController {
    var profileImage: UIImageView?
    var nameLabel : UILabel?
    var loginLabel : UILabel?
    enum Colors {
        static let black = UIColor(named: "YP Black")
        static let white = UIColor(named: "YP White")
        static let gray = UIColor(named: "YP Gray")
        static let red = UIColor(named: "YP Red")
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        setUpProfileImageView()
        setUpNameLabel()
        setUpLoginLabel()
        setUpDescriptionLabel()
        setUpLogoutButton()
    }
    
    private func setUpProfileImageView() {
        let image = UIImage(named: "profileImage")
        let profileImage = UIImageView(image: image)
        
        
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
        profileImage.widthAnchor.constraint(equalToConstant: 70),
        profileImage.heightAnchor.constraint(equalToConstant: 70),
        profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16),
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)])
        self.profileImage = profileImage
    }
    
    
   private func setUpNameLabel() {
        
        let nameLabel = UILabel()
        guard let profileImage else { return }

        nameLabel.text = "Наталья Черномырдина"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = Colors.white
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor,constant: 8)])
        self.nameLabel = nameLabel
    }
    
   private func setUpLoginLabel() {
        let loginLabel = UILabel()
        guard let nameLabel else { return }
       
        loginLabel.text = "@chernomyrdina_nata"
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = Colors.gray

        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        NSLayoutConstraint.activate([
        loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)])
        self.loginLabel = loginLabel
    }
    
  private func setUpDescriptionLabel() {
        let descriptionLabel = UILabel()
        guard let loginLabel else {return}
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = Colors.white
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor,constant: 8)])
    }
    
  private func setUpLogoutButton () {
        let logoutImage = UIImage(named: "logout")
        guard let logoutImage else { return }
        guard let profileImage else { return }
        let logoutButton = UIButton.systemButton(with: logoutImage,target: self,action: nil)
        logoutButton.tintColor = Colors.red
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
        logoutButton.widthAnchor.constraint(equalToConstant: 44),
        logoutButton.heightAnchor.constraint(equalToConstant: 44),
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
        logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)])
    }
}
