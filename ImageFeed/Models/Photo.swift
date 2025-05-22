//
//  Photo.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 16.05.2025.
//  Модель отдельного экземпляра фотографии используется в UI приложения

import UIKit

// MARK: - UI Model
struct Photo {
    
    // MARK: - Public Properties
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

// MARK: - API to UI Conversion
extension Photo {
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        
        let formatter = ISO8601DateFormatter()
        self.createdAt = result.createdAt.flatMap { formatter.date(from: $0) }
        
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
