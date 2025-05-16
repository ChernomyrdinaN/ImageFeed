//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 16.05.2025.
//  Модель для декодирования JSON из API Unsplash

import UIKit

// MARK: - Unsplash API Response Models
struct PhotoResult: Decodable {
    
    // MARK: - Public Properties
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id, width, height
        case createdAt = "created_at"
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String   
}
