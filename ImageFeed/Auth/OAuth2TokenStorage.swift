//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
// Хранилище токена

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get { UserDefaults.standard.string(forKey: "bearerToken") }
        set { UserDefaults.standard.set(newValue, forKey: "bearerToken") }
    }
}

