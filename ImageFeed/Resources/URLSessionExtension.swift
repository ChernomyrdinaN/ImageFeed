//
//  URLSessionExtension.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.05.2025.
//
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
            // 1. Логирование и обработка ошибки запроса
            if let error = error {
                print("❌ Сетевая ошибка: \(error.localizedDescription)")
                self.completeOnMainThread(.failure(NetworkError.networkError(error)), completion: completion)
                return
            }
            
            // 2. Проверяем, что ответ является HTTP-ответом
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Невалидный ответ сервера")
                self.completeOnMainThread(.failure(NetworkError.invalidResponse), completion: completion)
                return
            }
            
            // 3. Логирование данных ответа
            if let data = data,
 let responseString = String(data: data, encoding: .utf8) {
                print("⬇️ Получен ответ (\(httpResponse.statusCode)): \(responseString)")
            }
            
            // 4. Проверяем статус код
            switch httpResponse.statusCode {
            case 200..<300:
                // 5. Проверяем наличие данных
                guard let data = data else {
                    print("❌ Отсутствуют данные в ответе")
                    self.completeOnMainThread(.failure(NetworkError.invalidResponse),completion: completion)
                    return
                }
                
                // 6. Пытаемся декодировать данные
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    print("✅ Успешно декодирован объект типа \(T.self)")
                    self.completeOnMainThread(.success(decodedObject), completion: completion)
                } catch {
                    print("❌ Ошибка декодирования: \(error.localizedDescription)")
                    self.completeOnMainThread(.failure(NetworkError.decodingError(error)), completion: completion)
                }
                
            case 300..<400:
                let description = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                print("❌ Ошибка перенаправления (\(httpResponse.statusCode)): \(description)")
                self.completeOnMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)), completion: completion)
                
            default:
                if let data = data,
                   let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                    print("❌ Ошибка API: \(apiError.errorDescription)")
                    self.completeOnMainThread(.failure(NetworkError.apiError(apiError.errorDescription)), completion: completion)
                } else {
                    print("❌ HTTP ошибка: \(httpResponse.statusCode)")
                    self.completeOnMainThread(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)), completion: completion)
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
