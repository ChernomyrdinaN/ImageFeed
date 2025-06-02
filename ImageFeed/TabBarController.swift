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
        
        guard let imagesListVC = storyboard.instantiateViewController(
                    withIdentifier: "ImagesListViewController"
                ) as? ImagesListViewController else {
                    fatalError("Не удалось загрузить ImagesListViewController из storyboard")
                }
        
        let imagesListPresenter = ImagesListPresenter()
                imagesListVC.configure(imagesListPresenter)
        
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenter()
        
        profileVC.configure(presenter)
        configureProfileTabItem(for: profileVC)
        
        self.viewControllers = [imagesListVC, profileVC]
        print("[TabBarController]: Успешная настройка таба с 2 вкладками (лента,профиль)")
    }
    
    private func configureProfileTabItem(for controller: UIViewController) {
        controller.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
    }
}
