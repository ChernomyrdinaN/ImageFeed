//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//

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
        
        if isFetching {
            print("[OAuth2Service.fetchOAuthToken]: Request already in progress")
            return
        }
        
        if lastCode == code {
            print("[OAuth2Service.fetchOAuthToken]: DuplicateRequest - запрос с кодом \(code) уже выполняется")
            return
        }
        
        task?.cancel()
        lastCode = code
        isFetching = true
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            isFetching = false  
            let error = AuthServiceError.invalidRequest
            print("[OAuth2Service.fetchOAuthToken]: \(error) - не удалось создать запрос для кода: \(code)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            self.isFetching = false 
            
            switch result {
            case .success(let tokenResponse):
                let bearerToken = "Bearer \(tokenResponse.accessToken)"
                OAuth2TokenStorage.shared.token = bearerToken
                print("✅ Успешно получен токен \(tokenResponse)")
                DispatchQueue.main.async {
                    completion(.success(bearerToken))
                    self.task = nil
                    self.lastCode = nil
                }
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error) - код: \(code)")
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
}
