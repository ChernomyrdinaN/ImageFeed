//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Сервис для получения профиля пользователя Unsplash
//
import Foundation

final class ProfileService {
    // MARK: - Singleton Instance
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Public Methods
    func fetchProfile(
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        // Отмена предыдущей задачи
        task?.cancel()
        
        // Проверка токена
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(ProfileImageServiceError.unauthorized))
            return
        }
        
        // Создание и выполнение запроса
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        performProfileRequest(request: request, completion: completion)
    }
    
    // MARK: - Request Configuration
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
    
    // MARK: - Request Execution
    private func performProfileRequest(
        request: URLRequest,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Обработка ошибок запроса
            if let error = self.handleRequestError(data: data, response: response, error: error) {
                self.completeOnMainThread(.failure(error), completion: completion)
                return
            }
            
            // Валидация ответа
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                self.completeOnMainThread(.failure(NetworkError.invalidResponse), completion: completion)
                return
            }
            
            // Обработка статус кода
            self.handleStatusCode(
                httpResponse.statusCode,
                data: data,
                completion: completion
            )
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Response Handling
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
            do {
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = Profile(from: profileResult)
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
    
    // MARK: - Completion Handling
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
}
