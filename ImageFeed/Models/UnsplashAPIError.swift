//
//  UnsplashAPIError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//  Модель для обработки ошибок API Unsplash

// MARK: - UnsplashAPIError
struct UnsplashAPIError: Decodable {
    
    // MARK: - Public Properties
    let error: String
    let errorDescription: String
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
