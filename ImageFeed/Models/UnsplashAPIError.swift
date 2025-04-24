//
//  UnsplashAPIError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//  Модель ошибки API

import Foundation

struct UnsplashAPIError: Decodable {
    let error: String
    let errorDescription: String
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
