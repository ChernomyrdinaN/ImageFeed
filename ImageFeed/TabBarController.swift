//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 08.05.2025.
//  Отвечает за настройку и управление нижней панелью вкладок (Tab Bar) в приложении

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
        tabBar.barTintColor = Colors.black
        tabBar.tintColor = Colors.white
        tabBar.unselectedItemTintColor = UIColor.gray
        tabBar.isTranslucent = false
        tabBar.backgroundColor = Colors.black
    }
    
    // MARK: View Controllers Setup
    private func setupViewControllers() {
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .fullScreen
        
        
        // Настройка иконок
        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        // Упаковка в NavigationController
        let imagesListNav = UINavigationController(rootViewController: imagesListVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        // Установка контроллеров
        viewControllers = [imagesListNav, profileNav]
    }
}
