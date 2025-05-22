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
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

// MARK: - API to UI Conversion
extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt 
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
