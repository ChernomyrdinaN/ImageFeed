//
//  Constants.swift.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 12.04.2025.
//

import Foundation

enum Constants {
    static let accessKey = "tc9RkTczPzHb5WGxs2r3PJQMNgxnY0Vm8U1kOscZZFY"
    static let secretKey = "X1EFXKG0-u1SOAuE8TGQuqcXeXSUMRZF_ezUxUGZOWo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes" // список доступов
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")! // базовый адрес API
}
