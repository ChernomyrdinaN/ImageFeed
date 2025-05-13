//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.04.2025.
//  Модель успешного ответа OAuth

// MARK: - OAuthTokenResponseBody
struct OAuthTokenResponseBody: Decodable {
    
    // MARK: - Public Properties
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    // MARK: - Private Types
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

