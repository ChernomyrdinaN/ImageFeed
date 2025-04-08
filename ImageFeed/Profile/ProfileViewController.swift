//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//
import UIKit


final class ProfileViewController: UIViewController {
    private var label: UILabel? // добавили свойство во ВьюКонтроллер
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // главное Вью
        view.backgroundColor = UIColor(named: "YP Black") //используем цвета проекта
        
        // экран Профиль
        
        //let profileImage = UIImage(systemName: "person.crop.circle.fill") //создание объекта-изображения
        // let imageView = UIImageView(image: profileImage) // создание объекта-представления для изображения, создание Вью
        //imageView.tintColor = .gray // настраиваем цвет
        
        let profileImage = UIImageView()
        if let image = UIImage(named: "profileImage") { //загружаем изображение из ресурсов проекта
               profileImage.image = image
        }
        profileImage.translatesAutoresizingMaskIntoConstraints = false // отключаем создание констрейнов из маски
        view.addSubview(profileImage) // добавление Вью в иерархию
        NSLayoutConstraint.activate ([ // оптимизируем включение констрейнтов
            profileImage.widthAnchor.constraint(equalToConstant: 70), // задаем размеры
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20), // слева отступ 20
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20) // сверху от сейфарея отступ 20
                                     ])
        
        // размещаем имя
        
        let nameLabel = UILabel() // создание нового экземпляра класса UILabel
        
        nameLabel.text = "Екатерина Новикова" // настраиваем экземпляр
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false // отключаем создание констрейнов из маски
        view.addSubview(nameLabel) // добавление объекта в иерархию представлений
        NSLayoutConstraint.activate([ // оптимизируем включение констрейнтов
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor), // лейбл слева на таком же уровне что и иконка профиля
            nameLabel.topAnchor.constraint(equalTo:profileImage.bottomAnchor, constant: 20)]) // лейбл находится под иконкой с отступом от нее вниз на 20 пунктов
        
        let loginLabel = UILabel() // создание нового экземпляра класса UILabel
        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginLabel.textColor = UIColor(named: "YP Gray")
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        NSLayoutConstraint.activate([ // оптимизируем включение констрейнтов
            loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor), // лейбл слева на таком же уровне что и иконка профиля
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20)]) // лейбл находится под иконкой с отступом от нее вниз на 20 пунктов
        
        
        let descriptionLabel = UILabel() // создание нового экземпляра класса UILabel
        
        descriptionLabel.text = "Hello, world!" // настраиваем экземпляр
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false // отключаем создание констрейнов из маски
        view.addSubview(descriptionLabel) // добавление объекта в иерархию представлений
        NSLayoutConstraint.activate([ // оптимизируем включение констрейнтов
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor), // лейбл слева на таком же уровне что и иконка профиля
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 20)]) // лейбл находится под иконкой с отступом от нее вниз на 20 пунктов
        
        let logoutButton = UIButton.systemButton( // создание кнопки-объекта UIButton с системным изображением
            with: UIImage(systemName: "ipad.and.arrow.forward")!, // создается изображение, развертывание опционала - изображение навернка успешно
            target: self, // сам объект обрабатывает событие нажатия на кнопку
            action: #selector(self.logoutTapped) // при нажатии на кнопку вызывается метод didTapButton
        )
        logoutButton.tintColor = .red // настройка кнопки (цвет)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false // отключение старого метода расчетов констрейнтов
        view.addSubview(logoutButton) // добавление кнопки в иерархию представлений
        NSLayoutConstraint.activate([ // включение констрейнтов
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -20), // 20 пунктов от правого сейфарея
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor)]) // совпадает горизонтально по центру с иконкой
    }
    
    @objc // функция может использоваться в Objective-C
    private func logoutTapped() { // метод обработки нажатия кнопки
        label?.removeFromSuperview() // удаление элемента(текста) из лейбла
        label = nil // это значит что лейбл не ссылается на какой либо объект,это освобождает память
    }
}
