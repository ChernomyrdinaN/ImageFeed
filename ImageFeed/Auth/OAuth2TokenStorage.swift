//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//
//  Хранилище для OAuth2 токена, использует KeychainWrapper для безопасного хранения

import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage
final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() { checkFirstLaunch() }
    
    // MARK: - Keychain Setup
    private let keychain = KeychainWrapper.standard
    private let tokenKey = "accessToken"
    private let launchedBeforeKey = "был запущен ранее"
    
    // MARK: - Token Management
    var token: String? {
        get { keychain.string(forKey: tokenKey) }
        set {
            if let token = newValue {
                let saved = keychain.set(token, forKey: tokenKey)
                print(saved ? "[OAuth2TokenStorage]: Токен сохранен" : "[OAuth2TokenStorage]: Ошибка сохранения токена")
            } else {
                let removed = keychain.removeObject(forKey: tokenKey)
                print(removed ? "[OAuth2TokenStorage]: Токен очищен" : "[OAuth2TokenStorage]: Токен отсутствовал")
            }
        }
    }
    
    // MARK: - First Launch Check
    private func checkFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: launchedBeforeKey) else { return }
        clearToken()
        UserDefaults.standard.set(true, forKey: launchedBeforeKey)
        print("[OAuth2TokenStorage]: Первый запуск - гарантированная очистка токена")
    }
    
    // MARK: - Public Methods
    public final func clearToken() {
        token = nil
    }
}
