//
//  URLSessionExtension.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.05.2025.

import Foundation

extension URLSession {
    // Метод для выполнения запроса и декодирования ответа в Decodable-объект
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        // Создаем задачу на запрос
        let task = dataTask(with: request) {
            data,
            response,
            error in
            // Обрабатываем ошибки сети
            if let error {
                let networkError = NetworkError.networkError(error)
                print("[objectTask]: \(networkError) - URL: \(request.url?.absoluteString ?? "nil")")
                self.completeOnMainThread(.failure(networkError), completion: completion)
                return
            }
            
            // Проверяем HTTP-ответа
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NetworkError.invalidResponse
                print("[objectTask]: \(error) - URL: \(request.url?.absoluteString ?? "nil")")
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            // Логируем данные ответа
            if let data, let responseString = String(data: data, encoding: .utf8) {
                print("[objectTask]: Получены данные (\(httpResponse.statusCode)) - \(responseString.prefix(200))...")
            }
            
            
            // Проверяем статус код
            switch httpResponse.statusCode {
            case 200..<300:
                // 5. Проверяем наличие данных
                guard let data else {
                    let error = NetworkError.invalidResponse
                    print("[objectTask]: \(error) - нет данных в ответе, URL: \(request.url?.absoluteString ?? "nil")")
                    self.completeOnMainThread(.failure(error), completion: completion)
                    return
                }
                // Пытаемся декодировать данные
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    self.completeOnMainThread(.success(decodedObject), completion: completion)
                } catch let decodingError {
                    let dataString = String(data: data, encoding: .utf8) ?? "Не удалось преобразовать данные"
                    let error = NetworkError.decodingError(decodingError)
                    print("[objectTask]: \(error) - Данные: \(dataString.prefix(200))...")
                    self.completeOnMainThread(.failure(error), completion: completion)
                }
                
            default:
                if let data,
                   let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                    let error = NetworkError.apiError(apiError.errorDescription)
                    print("[objectTask]: \(error) - URL: \(request.url?.absoluteString ?? "nil")")
                    self.completeOnMainThread(.failure(error), completion: completion)
                } else {
                    let error = NetworkError.httpStatusCode(httpResponse.statusCode)
                    print("[objectTask]: \(error) - URL: \(request.url?.absoluteString ?? "nil")")
                    self.completeOnMainThread(.failure(error), completion: completion)
                }
            }
        }
        return task
    }
    
    // Выполнение completion на главном потоке
    private func completeOnMainThread<T>(
        _ result: Result<T, Error>,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
