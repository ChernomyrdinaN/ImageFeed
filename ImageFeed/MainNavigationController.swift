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
        navigationBar.barTintColor = Colors.black
        navigationBar.tintColor = Colors.black
        navigationBar.backgroundColor = Colors.black
        view.insetsLayoutMarginsFromSafeArea = false
        
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            UIOffset(horizontal: -100, vertical: 0),
            for: .default
        )
    }
}

