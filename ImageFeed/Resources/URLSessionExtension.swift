//
//  URLSessionExtension.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.05.2025.
//
//  Расширение для URLSession, дженерик-метод для выполнения сетевых запросов с автоматическим декодированием JSON и единой системой ошибок для всех запросов

import Foundation

extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let task = dataTask(with: request) {data,response,error in
            if let error {
                let networkError = NetworkError.networkError(error)
                print("[URLSession.objectTask|\(T.self)]: Error \(networkError)")
                self.completeOnMainThread(.failure(networkError), completion: completion)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NetworkError.invalidResponse
                print("[URLSession.objectTask]: Error \(error) - URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            if let data, let _ = String(data: data, encoding: .utf8) {
                print("[URLSession.objectTask|\(T.self)]: Ответ (\(httpResponse.statusCode)). Тип: \(T.self)")
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                
                guard let data else {
                    let error = NetworkError.invalidResponse
                    print("[URLSession.objectTask]: Error \(error) - URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
                    self.completeOnMainThread(.failure(error), completion: completion)
                    return
                }
                
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    print("[URLSession.objectTask]: Успех - данные декодированы. Тип: \(T.self)")
                    self.completeOnMainThread(.success(decodedObject), completion: completion)
                } catch let decodingError {_ = String(data: data,encoding: .utf8) ?? "Не удалось преобразовать данные"
                    let error = NetworkError.decodingError(decodingError)
                    print("[URLSession.objectTask]: Error \(error) - URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
                    self.completeOnMainThread(.failure(error), completion: completion)
                }
                
            default:
                if let data,
                   let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                    let error = NetworkError.apiError(apiError.errorDescription)
                    print("[URLSession.objectTask]: Error \(error) - URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
                    self.completeOnMainThread(.failure(error), completion: completion)
                } else {
                    let error = NetworkError.httpStatusCode(httpResponse.statusCode)
                    print("[URLSession.objectTask]: Статус - задача создана для URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
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
