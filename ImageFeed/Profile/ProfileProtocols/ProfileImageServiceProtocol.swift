//
//  ProfileImageServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Определяет протокол сервиса загрузки фото(профиля)

import Foundation

// MARK: - ProfileImageServiceProtocol 
protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}
