//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Перечисление ошибок сети

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)  // HTTP-код состояния, 401-500
    case networkError(Error) // ошибка сеанса URL, нет подключения к интернету, таймаут
    case invalidResponse    // неверный ответ, не соответствует ожидаемому, нет данных, data == nil, заголовки или структура ответа некорректны
    case apiError(String)  // Кастомная ошибка API (если API возвращает {"error": "..."})
    case invalidURL       // Некорректный URL
    case tokenDecodingError(Error) // ошибка декодирования токена
    case decodingError(Error) // ошибка декодирования профиля
}
