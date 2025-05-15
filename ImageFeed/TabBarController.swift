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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewControllers()
    }
    
    // MARK: - Private Methods
    
    private func setupViewControllers() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        let profileViewController = ProfileViewController()
        configureProfileTabItem(for: profileViewController)
        
        self.viewControllers = [imagesListViewController, profileViewController]
        print("[TabBarController]: Успешная настройка таба с 2 вкладками (лента,профиль)")
    }
    
    private func configureProfileTabItem(for controller: UIViewController) {
        controller.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "person.circle"),
            selectedImage: nil
        )
    }
}
