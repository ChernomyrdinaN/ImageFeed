//
//  Constants.swift.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//  Константы приложения для работы с Unsplash API - содержит ключи доступа и параметры для работы с API Unsplash

import Foundation

// MARK: - Constants
enum Constants {
    
    // MARK: - API Keys
    static let accessKey = "tc9RkTczPzHb5WGxs2r3PJQMNgxnY0Vm8U1kOscZZFY" 
    static let secretKey = "X1EFXKG0-u1SOAuE8TGQuqcXeXSUMRZF_ezUxUGZOWo"
    
    // MARK: - OAuth Configuration
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    // MARK: - API Configuration
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com")
}
