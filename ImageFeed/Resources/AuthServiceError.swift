//
//  AuthServiceError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.04.2025.
//  Перечисление ошибок сервиса

import Foundation

enum AuthServiceError: Error {
    case invalidRequest // недействительный запрос, запрос на аутентификацию
}
