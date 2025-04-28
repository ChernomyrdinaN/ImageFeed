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
        assert(Thread.isMainThread) // проверяем, что код выполняется на главном потоке, чтобы отловить гонки данных
        
        if let task = task { // предотвращаем повторный вызов с одинаковым code
            if lastCode != code { // предотвращаем вызов с новым code до завершения предыдущего
                task.cancel() // если запрос уже выполняется с тем же code → возвращает ошибку, если code новый → отменяет старый запрос и начинает новый
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        let request = makeOAuthTokenRequest(code: code) // создаем и выполняем запрос
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = self.handleRequestError(data: data, response: response, error: error) {
                DispatchQueue.main.async {
                    completion(.failure(error)) // обеспечиваем гарантированный результат работы fetchOAuthToken при ошибке запроса
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse)) // обеспечиваем гарантированный результат работы fetchOAuthToken при невалидном ответе
                }
                return
            }
            
            self.logResponseData(data: data)
            
            self.handleStatusCode(
                httpResponse.statusCode,
                data: data,
                onSuccess: { tokenResponse in
                    let bearerToken = "Bearer \(tokenResponse.accessToken)" // сохранение токена    
                    OAuth2TokenStorage.shared.token = bearerToken
                    print("✅ Успешно получен токен")
                    DispatchQueue.main.async {
                        completion(.success(bearerToken)) // обеспечиваем гарантированный результат работы fetchOAuthToken при успехе
                    }
                },
                onFailure: { error in
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            )
            
            DispatchQueue.main.async {
                self.task = nil // после завершения запроса поля обнуляются
                self.lastCode = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest { // создание запроса
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            fatalError("Failed to create URL")
        }
        
        let params = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code, // временный код из WebViewViewController
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
        request.timeoutInterval = 30 // если сервер не отвечает, запрос отмениться
        
        return request
    }
    
    private func handleRequestError(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Error? { // проверка ошибок
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
    
    private func logResponseData(data: Data) { // логирование ответа
        if let responseString = String(data: data, encoding: .utf8) {
            print("⬇️ Получен ответ: \(responseString)")
        }
    }
    
    private func handleStatusCode( // обработка http-статуса
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
