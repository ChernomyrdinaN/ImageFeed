//
//  MainNavigationController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 13.05.2025.
//
import UIKit

// MARK: - MainNavigationController
final class MainNavigationController: UINavigationController {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupNavigationAppearance()
    }
    
    // MARK: - Private Methods
    private func setupNavigationAppearance() {
        // 1. Базовые настройки Navigation Bar
        navigationBar.barTintColor = Colors.black  // Фон бара
        navigationBar.tintColor = Colors.white     // Цвет кнопок
        navigationBar.backgroundColor = Colors.black
        view.insetsLayoutMarginsFromSafeArea = false
        
        // 2. Настройка заголовка
        navigationBar.titleTextAttributes = [
            .foregroundColor: Colors.white as Any,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        // 3. Настройка кнопки "Назад" (убираем текст, оставляем только иконку)
        navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -100, vertical: 0),
            for: .default
        )
        
        print("[MainNavigationController]: Настройка завершена")
    }
}
