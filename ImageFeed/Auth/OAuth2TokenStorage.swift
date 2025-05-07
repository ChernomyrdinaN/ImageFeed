//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//  Хранение токена
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let keychain = KeychainWrapper.standard
    private let tokenKey = "bearerToken"
   
    var token: String? {
            get { keychain.string(forKey: tokenKey) }
            set {
                if let value = newValue {
                    keychain.set(value, forKey: tokenKey)
                } else {
                    keychain.removeObject(forKey: tokenKey)
                }
            }
        }
        private init() {}
    }
