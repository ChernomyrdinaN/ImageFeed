//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Сервис для получения профиля пользователя Unsplash
//
import Foundation

final class ProfileService {
    static let shared = ProfileService() 
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if let task = task {
            print("⚠️ Отмена предыдущего запроса профиля")
            task.cancel()
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(ProfileImageServiceError.unauthorized))
            return
        }
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = self.handleRequestError(data: data, response: response, error: error) {
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                self.completeOnMainThread(.failure(NetworkError.invalidResponse), completion: completion)
                return
            }
            
            self.handleStatusCode(
                httpResponse.statusCode,
                data: data,
                completion: completion
            )
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create URL for profile request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        return request
    }
    
    private func completeOnMainThread(
        _ result: Result<Profile, Error>,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            if case .success(let profile) = result {
                self?.profile = profile
            }
            completion(result)
            self?.task = nil
        }
    }
    
    private func handleRequestError(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Error? {
        if let error = error {
            return NetworkError.networkError(error)
        }
        
        guard response is HTTPURLResponse else {
            return NetworkError.invalidResponse
        }
        
        return nil
    }
    
    private func handleStatusCode(
        _ statusCode: Int,
        data: Data,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        switch statusCode {
        case 200..<300:
            do {//print("Raw data before decoding: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = Profile(from: profileResult)
                //print("✅ Успешно получен профиль: \(profile)")
                completeOnMainThread(.success(profile), completion: completion)
            } catch {
                print("❌ Ошибка декодирования профиля: \(error.localizedDescription)")
                completeOnMainThread(.failure(NetworkError.decodingError(error)), completion: completion)
            }
            
        case 401:
            print("❌ Ошибка авторизации: неверный токен")
            completeOnMainThread(.failure(ProfileImageServiceError.unauthorized), completion: completion)
            
        default:
            if let apiError = try? JSONDecoder().decode(UnsplashAPIError.self, from: data) {
                completeOnMainThread(.failure(NetworkError.apiError(apiError.errorDescription)), completion: completion)
            } else {
                completeOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)), completion: completion)
            }
        }
    }
}
