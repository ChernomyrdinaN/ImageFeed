//
//  Constants.swift.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//

import Foundation

enum Constants {
    static let accessKey = "<ваш Access Key>"
    static let secretKey = "<ваш Secret Key>"
    static let redirectURI = "<ваш Redirect URI>"
    static let accessScope = "public+read_user+write_likes" // список доступов
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")! // базовый адрес API
}
