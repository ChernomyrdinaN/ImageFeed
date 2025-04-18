//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 18.04.2025.
// Сетевой клиент для выполнения HTTP-запросов

import Foundation

protocol NetworkClientProtocol { //определяет контракт для сетевого клиента
    func fetch(
        url: URL,
        method: String, // "GET", "POST" и т.д.
        headers: [String: String]?,
        body: Data?,
        handler: @escaping (Result<Data, Error>) -> Void
    )
}

struct NetworkClient: NetworkClientProtocol {
    
    private enum NetworkError: Error { // кастомная ошибка, орабатывает HTTP-коды ошибок
        case codeError(Int)
    }
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func fetch(
        url: URL,
        method: String = "GET", // По умолчанию GET
        headers: [String: String]? = nil,
        body: Data? = nil,
        handler: @escaping (Result<Data, Error>) -> Void
    ) {
        // 1. Создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = method // Устанавливаем метод (GET/POST/etc)
        request.timeoutInterval = 30 // 30 сек
        
        // 2. Добавляем заголовки (если есть)
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // 3. Для POST-запросов добавляем тело
        if let body = body {
            request.httpBody = body
        }
        
        // 4. Создаем и выполняем задачу
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка результата (остается без изменений)
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError(response.statusCode)))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}


