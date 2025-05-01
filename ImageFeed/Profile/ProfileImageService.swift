//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.
//
import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if let task = task {
            print("⚠️ Отмена предыдущего запроса аватарки")
            task.cancel()
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(ProfileImageServiceError.unauthorized))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
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
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            assertionFailure("Failed to create URL for profile image request")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        return request
    }
    
    private func completeOnMainThread(
        _ result: Result<String, Error>,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            if case .success(let avatarURL) = result {
                self?.avatarURL = avatarURL
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
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch statusCode {
        case 200..<300:
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = userResult.profileImage.small
                completeOnMainThread(.success(avatarURL), completion: completion)
            } catch {
                print("❌ Ошибка декодирования URL аватарки: \(error.localizedDescription)")
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
