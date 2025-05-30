//
//  Constants.swift
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
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: - AuthConfiguration
struct AuthConfiguration {
    
    // MARK: - Properties
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let authURLString: String
    
    // MARK: - Initialization
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL? = nil) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    // MARK: - Standard Configuration
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL
        )
    }
}
