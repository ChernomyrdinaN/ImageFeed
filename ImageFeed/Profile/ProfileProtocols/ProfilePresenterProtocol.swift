//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Определяет интерфейс для презентера профиля пользователя 

import Foundation

// MARK: - Profile Presenter Protocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
}
