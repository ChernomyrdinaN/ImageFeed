//
//  AuthHelperProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//
//  Протокол для работы с OAuth-аутентификацией

import Foundation

// MARK: - AuthHelperProtocol
protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
