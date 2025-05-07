//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Сервис отвечает за аутентификацию пользователя через OAuth 2.0

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var isFetching = false
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        print("[OAuth2Service.fetchOAuthToken]: Статус - запрос запущен. Код: \(code.prefix(4))...")
        if isFetching {
            print("[OAuth2Service.fetchOAuthToken]: Warning - активный запрос. Текущий код: \(lastCode?.prefix(4) ?? "nil")")
            return
        }
        
        if lastCode == code {
            print("[OAuth2Service.fetchOAuthToken]: Warning - дубликат запроса. Код: \(code.prefix(4))...")
            return
        }
        
        task?.cancel()
        lastCode = code
        isFetching = true
        print("[OAuth2Service.fetchOAuthToken]: Статус - isFetching: \(isFetching)")
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            isFetching = false
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - неверный запрос. Код: \(code.prefix(4))...")
            let error = AuthServiceError.invalidRequest
            print("[OAuth2Service.makeOAuthTokenRequest]: \(error) - не удалось создать запрос для кода: \(code)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            print("Ошибка: \(AuthServiceError.invalidRequest)")
            return
        }
        print("[OAuth2Service.fetchOAuthToken]: Статус - отправка запроса. URL: \(request.url?.absoluteString ?? "nil")")
        print("[OAuth2Service.fetchOAuthToken]: Параметры - \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")")
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            self.isFetching = false
            print("[OAuth2Service.fetchOAuthToken]: Статус - запрос завершен")
            
            switch result {
            case .success(let tokenResponse):
                let bearerToken = "Bearer \(tokenResponse.accessToken)"
                OAuth2TokenStorage.shared.token = bearerToken
                
                print("[OAuth2Service.fetchOAuthToken]: Успех - токен получен. Начало: \(bearerToken.prefix(5))...")
                DispatchQueue.main.async {
                    completion(.success(bearerToken))
                    self.task = nil
                    self.lastCode = nil
                }
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: Error \(error.localizedDescription). Код: \(code.prefix(4))...")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                    self.lastCode = nil
                }
            }
        }
        
        task?.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service.makeOAuthTokenRequest]: Error - неверный URL")
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
}
