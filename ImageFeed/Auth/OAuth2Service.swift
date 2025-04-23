//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Сервис авторизации

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
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = makeOAuthTokenRequest(code: code)
        print("➡️ Отправка запроса токена...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = self.handleRequestError(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            self.logResponseData(data: data)
            
            self.handleStatusCode(
                httpResponse.statusCode,
                data: data,
                onSuccess: { tokenResponse in
                    let bearerToken = "Bearer \(tokenResponse.accessToken)"
                    OAuth2TokenStorage.shared.token = bearerToken
                    print("✅ Успешно получен токен")
                    DispatchQueue.main.async {
                        completion(.success(bearerToken))
                    }
                },
                onFailure: { error in
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            )
        }
        
        task.resume()
    }
    
    private func handleRequestError( // обработка ошибок
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Error? {
        if let error = error {
            print("❌ Сетевая ошибка: \(error.localizedDescription)")
            return NetworkError.urlRequestError(error)
        }
        
        guard let _ = response as? HTTPURLResponse else {
            print("❌ Невалидный ответ сервера")
            return NetworkError.invalidResponse
        }
        
        guard data != nil else {
            print("❌ Отсутствуют данные в ответе")
            return NetworkError.invalidResponse
        }
        
        return nil
    }
    
    private func logResponseData(data: Data) { // логирование
        if let responseString = String(data: data, encoding: .utf8) {
            print("⬇️ Получен ответ: \(responseString)")
        }
    }
    
    private func handleStatusCode( // обработка статус-кодов
        _ statusCode: Int,
        data: Data,
        onSuccess: (OAuthTokenResponseBody) -> Void,
        onFailure: (Error) -> Void
    ) {
        switch statusCode {
        case 200..<300:
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                onSuccess(tokenResponse)
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                onFailure(NetworkError.tokenDecodingError(error))
            }
            
        case 300..<400:
            let description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            print("❌ Ошибка перенаправления (\(statusCode)): \(description)")
            onFailure(NetworkError.httpStatusCode(statusCode))
            
        default:
            if let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                print("❌ Ошибка API: \(apiError.errorDescription)")
                onFailure(NetworkError.apiError(apiError.errorDescription))
            } else {
                print("❌ HTTP ошибка: \(statusCode)")
                onFailure(NetworkError.httpStatusCode(statusCode))
            }
        }
    }
}
