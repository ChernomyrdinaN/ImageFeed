//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//
import UIKit


final class ProfileViewController: UIViewController {
    var profileImage: UIImageView? // задаем опциональные переменные для Вьюх
    var nameLabel : UILabel?
    var loginLabel : UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setUpProfileImageView()
        setUpNameLabel()
        setUpLoginLabel()
        setUpDescriptionLabel()
        setUpLogoutButton()
    }
    
    func setUpProfileImageView() { // функция создания и настройки UIImage (изображение профиля) на вью
        let image = UIImage(named: "profileImage") // загружаем изображения из Assets
        let profileImage = UIImageView(image: image) // создаем UIImageView с этим изображением
        
        
        profileImage.layer.cornerRadius = 35 // скругляем углы изображения (радиус = 35pt)
        profileImage.layer.masksToBounds = true // обрезаем изображение по границам круга
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false // отключаем старые autoresizing-маски
        view.addSubview(profileImage) // добавляем UIImageView на главную вью
        
        NSLayoutConstraint.activate([
        profileImage.widthAnchor.constraint(equalToConstant: 70), // настраивем ширину и высоту изображения
        profileImage.heightAnchor.constraint(equalToConstant: 70),
        profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 16), // устанавливаем отступы с учетом safe area
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)])
        self.profileImage = profileImage // сохраняем imageView в свойство класса для последующего доступа из вне
    }
    
    
    func setUpNameLabel() { // функция создания и настройки UILabel (лейбла имени)
        
        let nameLabel = UILabel() // создаем новый экземпляр UILabel
        guard let profileImage else { return } // проверяем опциональную переменную (метка другой иерархии)

        nameLabel.text = "Наталья Черномырдина" // настраиваем текст и стиль
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold) // используем системный болд-шрифт размером 23pt
        nameLabel.textColor = UIColor(named: "YP White") // используем белый цвет из ресурсов
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor,constant: 8)])
        self.nameLabel = nameLabel
    }
    
    func setUpLoginLabel() { // функция создания и настройки UILabel (лейбла логина)
        let loginLabel = UILabel()
        guard let nameLabel else {return}
       
        loginLabel.text = "@chernomyrdina_nata"
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = UIColor(named: "YP Gray")
        
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        NSLayoutConstraint.activate([
        loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)])
        self.loginLabel = loginLabel
    }
    
    func setUpDescriptionLabel() { // функция создания и настройки UILabel (лейбла с описанием)
        let descriptionLabel = UILabel()
        guard let loginLabel else {return}
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White")
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor,constant: 8)])
    }
    
    func setUpLogoutButton () { // функция создания и настройки кнопки выхода
        let logoutImage = UIImage(named: "logout")
        guard let logoutImage else { return }
        guard let profileImage else { return }
        let logoutButton = UIButton.systemButton(with: logoutImage,target: self,action: nil)
        logoutButton.tintColor = UIColor(named: "YP Red")
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
        logoutButton.widthAnchor.constraint(equalToConstant: 44),
        logoutButton.heightAnchor.constraint(equalToConstant: 44),
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
        logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)])
    }
}
