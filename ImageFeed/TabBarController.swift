//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 08.05.2025.
//
import UIKit
 
final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func awakeFromNib() { // метод вызывается ситсемой как только TabBarController был настроен
        super.awakeFromNib()
        
        // MARK: - Setup ViewControllers
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
            // Создаем ImagesListViewController
            let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
            // Создаем ProfileViewController
            let profileViewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            // Назначаем контроллеры
            self .viewControllers = [imagesListViewController, profileViewController]
            print("[TabBarController]: Успех - TabBarController настроен с 2 табами")
            
        }
    }



