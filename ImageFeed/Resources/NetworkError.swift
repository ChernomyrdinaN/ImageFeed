//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Перечисление возможных сетевых ошибок при работе с API

import Foundation

// MARK: - NetworkError
enum NetworkError: Error {
    case httpStatusCode(Int)  // ошибка HTTP-статуса (коды 4xx/5xx)
    case networkError(Error) // ошибка сетевого соединения (таймаут, нет интернета)
    case invalidResponse    // невалидный ответ сервера
    case apiError(String)  // кастомная ошибка API (если API возвращает {"error": "..."})
    case invalidURL       // некорректный URL
    case tokenDecodingError(Error) //  ошибка декодирования токена
    case decodingError(Error) // ошибка декодирования данных (профиля и др.)
    
}
