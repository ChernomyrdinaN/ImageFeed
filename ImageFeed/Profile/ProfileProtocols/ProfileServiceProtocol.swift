//
//   ProfileServiceProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//

import Foundation

protocol ProfileServiceProtocol {
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void)
    var profile: Profile? { get }
}
