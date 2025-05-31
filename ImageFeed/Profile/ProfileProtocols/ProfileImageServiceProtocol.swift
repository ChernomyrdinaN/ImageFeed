//
//  ProfileImageServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//

import Foundation

protocol ProfileImageServiceProtocol {
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void)
    var avatarURL: String? { get }
}
