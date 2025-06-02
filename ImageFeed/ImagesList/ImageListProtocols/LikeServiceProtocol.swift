//
//  LikeServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//

import Foundation

// MARK: - LikeServiceProtocol Protocol
protocol LikeServiceProtocol {
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
