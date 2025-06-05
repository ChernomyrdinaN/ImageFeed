//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//   Определяет контракт для сервиса

import Foundation

// MARK: - ImagesListServiceProtocol Protocol
protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    
    func fetchPhotosNextPage( _ completion: @escaping (Result<[Photo], Error>) -> Void)
    
}
