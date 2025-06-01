//
//   ProfileServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//

import Foundation

// MARK: -  ProfileServiceProtocol
protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    
}
