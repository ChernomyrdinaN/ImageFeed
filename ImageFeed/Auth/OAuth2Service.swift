//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Cервис OAuth

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            fatalError("Failed to create URL")
        }
        
        let params = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = params
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyString.data(using: .utf8)
        
        return request
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = makeOAuthTokenRequest(code: code)
        print("➡️ Отправка запроса токена...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Сетевая ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlRequestError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Невалидный ответ сервера")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                print("❌ Отсутствуют данные в ответе")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            // Логирование сырого ответа
            if let responseString = String(data: data, encoding: .utf8) {
                print("⬇️ Получен ответ: \(responseString)")
            }
            
            // Обработка по статус коду
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let bearerToken = "Bearer \(tokenResponse.accessToken)"
                    OAuth2TokenStorage.shared.token = bearerToken
                    print("✅ Успешно получен токен")
                    DispatchQueue.main.async {
                        completion(.success(bearerToken))
                    }
                } catch {
                    print("❌ Ошибка декодирования: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.tokenDecodingError(error)))
                    }
                }
                
            default:
                if let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                    print("❌ Ошибка API: \(apiError.errorDescription)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.apiError(apiError.errorDescription)))
                    }
                } else {
                    print("❌ HTTP ошибка: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    }
                }
            }
        }
        
        task.resume()
    }
}
