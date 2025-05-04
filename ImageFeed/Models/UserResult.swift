//
//  UserResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
    }
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
