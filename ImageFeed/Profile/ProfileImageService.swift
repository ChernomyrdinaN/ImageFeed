//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.
//  Cервис для получения URL аватарки пользователя
//
import Foundation

final class ProfileImageService {
    // MARK: - Singleton Instance
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    // MARK: - Public Methods
    func fetchProfileImageURL( // подготавливает данные и запускает запрос
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
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
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        performImageRequest(request: request, completion: completion)
    }
    
    // MARK: - Request Configuration
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
    
    // MARK: - Request Execution
    private func performImageRequest( //выполняет сам запрос и передает результат
        request: URLRequest,
        completion: @escaping (Result<String, Error>) -> Void
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
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        switch statusCode {
        case 200..<300:
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                let avatarURL = userResult.profileImage.small
                
                // Отправка уведомления
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                
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
    
    // MARK: - Completion Handling
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
}
