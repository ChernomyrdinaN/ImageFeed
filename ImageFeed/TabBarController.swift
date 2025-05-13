//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 08.05.2025.
//  Отвечает за настройку и управление нижней панелью вкладок (Tab Bar) в приложении


//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 08.05.2025.
//

import UIKit

// MARK: - TabBarController
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupViewControllers()
    }
    
    // MARK: - Private Methods
    
    // MARK: Appearance Configuration
    private func configureAppearance() {
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
    }
    
    // MARK: View Controllers Setup
    private func setupViewControllers() {
        // 1. Создаем контроллеры
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        // 2. Настраиваем иконки
        configureTabBarItems(for: imagesListVC, profileVC)
        
        // 3. Упаковываем в NavigationController
        let controllers = wrapInNavigationControllers(imagesListVC, profileVC)
        
        // 4. Устанавливаем в TabBar
        viewControllers = controllers
    }
    
    // MARK: TabBar Items Configuration
    private func configureTabBarItems(for controllers: UIViewController...) {
        controllers[0].tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "rectangle.stack.fill"),
            tag: 0
        )
        
        controllers[1].tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person.crop.circle.fill"),
            tag: 1
        )
    }
    
    // MARK: Navigation Wrapping
    private func wrapInNavigationControllers(_ controllers: UIViewController...) -> [UINavigationController] {
        return controllers.map {
            let navController = UINavigationController(rootViewController: $0)
            navController.navigationBar.barStyle = .black
            return navController
        }
    }
}
