//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//
//  Хранилище для OAuth2 токена, использует KeychainWrapper для безопасного хранения

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() { checkFirstLaunch() }
    
    // MARK: - Keychain Setup
    private let keychain = KeychainWrapper.standard
    private let tokenKey = "accessToken"
    
    // MARK: - Token Management
    var token: String? {
        get {
            let token = keychain.string(forKey: tokenKey)
            print("[OAuth2TokenStorage]: Token status  \(token != nil ? "exists" : "nil")")  // получаем токен из Keychain
            return token
        }
        set {
            if let token = newValue {
                keychain.set(token, forKey: tokenKey) // сохраняем новый токен в Keychain
                print("[OAuth2TokenStorage]: Token saved")
            } else {
                keychain.removeObject(forKey: tokenKey) // удаляем токен из Keychain
                print("[OAuth2TokenStorage]: Token cleared")
            }
        }
    }
    
    // MARK: - First Launch Check
    private func checkFirstLaunch() {  // проверяет и обрабатывает первый запуск приложения
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: "wasLaunchedBefore") // проверяем, был ли уже запуск приложения
        if isFirstLaunch {
            clearToken()
            UserDefaults.standard.set(true, forKey: "wasLaunchedBefore")
            print("[OAuth2TokenStorage]: First launch - token cleared")
        }
    }
    
    // MARK: - Public Methods
    func clearToken() {    // явно очищает текущий токен
        token = nil
    }
}
