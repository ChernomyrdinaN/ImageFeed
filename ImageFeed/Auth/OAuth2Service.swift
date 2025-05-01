//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Сервис для получения OAuth-токена Unsplash

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            print("⚠️ Запрос с тем же кодом уже выполняется, отмена дубликата") // для отладки
            return
        }
        
        if let task = task {
            task.cancel()
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completeOnMainThread(.failure(AuthServiceError.invalidRequest),completion: completion
            )
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = self.handleRequestError(data: data, response: response, error: error) {
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data, !data.isEmpty else {
                print("❌ Невалидный ответ: данные пусты или ответ не является HTTP-ответом")
                self.completeOnMainThread(.failure(NetworkError.invalidResponse), completion: completion)
                return
            }
            
            self.logResponseData(data: data)
            self.handleStatusCode(
                httpResponse.statusCode,
                data: data,
                completion: completion
            )
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL for OAuth token request")
            return nil
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
        request.timeoutInterval = 30
        
        return request
    }
    
    private func completeOnMainThread(
        _ result: Result<String, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            completion(result)
            self?.task = nil
            self?.lastCode = nil
        }
    }
    
    private func handleRequestError(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Error? {
        if let error = error {
            print("❌ Сетевая ошибка: \(error.localizedDescription)")
            return NetworkError.networkError(error)
        }
        
        guard response is HTTPURLResponse else {
            print("❌ Невалидный ответ сервера")
            return NetworkError.invalidResponse
        }
        
        return nil
    }
    
    private func logResponseData(data: Data) {
        if let responseString = String(data: data, encoding: .utf8) {
            print("⬇️ Получен ответ: \(responseString)")
        }
    }
    
    private func handleStatusCode(
        _ statusCode: Int,
        data: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch statusCode {
        case 200..<300:
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let bearerToken = "Bearer \(tokenResponse.accessToken)"
                OAuth2TokenStorage.shared.token = bearerToken
                print("✅ Успешно получен токен \(tokenResponse)")
                completeOnMainThread(.success(bearerToken), completion: completion)
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                completeOnMainThread(.failure(NetworkError.tokenDecodingError(error)),completion: completion)
            }
            
        case 300..<400:
            let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            print("❌ Ошибка перенаправления (\(statusCode)): \(description)")
            completeOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)), completion: completion)
            
        default:
            if let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                print("❌ Ошибка API: \(apiError.errorDescription)")
                completeOnMainThread(.failure(NetworkError.apiError(apiError.errorDescription)), completion: completion)
            } else {
                print("❌ HTTP ошибка: \(statusCode)")
                completeOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)), completion: completion)
            }
        }
    }
}
