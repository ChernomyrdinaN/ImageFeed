//
//  UserResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.
//  Модель для обработки данных об аватаре пользователя из API Unsplash

struct UserResult: Codable {
    
    // MARK: - Nested Types
    let profileImage: ProfileImage
    
    // MARK: - Public Properties
    struct ProfileImage: Codable {
        let small: String
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
