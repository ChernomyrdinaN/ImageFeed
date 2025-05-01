//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Модель для декодирования JSON из API Unsplash

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let name: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case bio
    }
}
