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
    let id: String            // Уникальный идентификатор
    let size: CGSize          // Размеры изображения
    let createdAt: Date?      // Дата создания (опционально)
    let welcomeDescription: String?  // Описание фотографии (опционально)
    let thumbImageURL: String // URL миниатюры
    let largeImageURL: String // URL полноразмерного изображения
    let isLiked: Bool         // Отмечено ли как понравившееся
}

// MARK: - API to UI Conversion
extension Photo {
    // Инициализатор для преобразования API-модели (PhotoResult) в UI-модель (Photo)
    init(from result: PhotoResult, dateFormatter: ISO8601DateFormatter) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
