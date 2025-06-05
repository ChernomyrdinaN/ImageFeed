//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Модель для декодирования JSON из API Unsplash с тестовыми экземплярами для удобства тестирования

// MARK: - ProfileResult
struct ProfileResult: Codable {
    
    // MARK: - Public Properties
    let username: String
    let firstName: String?
    let lastName: String?
    let name: String?
    let bio: String?
    
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case bio
    }
}
