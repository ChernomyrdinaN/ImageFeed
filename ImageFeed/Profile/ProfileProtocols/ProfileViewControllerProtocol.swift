//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Определяет интерфейс для ViewController'а экрана профиля

import Foundation

// MARK: - Profile ViewController Protocol
protocol ProfileViewControllerProtocol: AnyObject {
    
    func updateProfileDetails(name: String, login: String, bio: String?)
    func updateAvatar(with url: URL)
    func showDefaultProfile()
    func showLogoutConfirmation(completion: @escaping () -> Void)
    func switchToSplashScreen()
}

