//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.
//  Cервис для получения URL аватарки пользователя

import Foundation

// MARK: - ProfileImageService
final class ProfileImageService {
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    private(set) var isFetching = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        print("[ProfileImageService.fetchProfileImageURL]: Статус - начало загрузки аватара для пользователя: \(username.prefix(6))...")
        
        guard !isFetching else {
            print("[ProfileImageService.fetchProfileImageURL]: Warning - запрос уже выполняется")
            return
        }
        
        isFetching = true
        task?.cancel()
        print("[ProfileImageService.fetchProfileImageURL]: Статус - предыдущий запрос отменен")
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: Error ProfileImageServiceError.unauthorized - токен отсутствует")
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.unauthorized))
                self.isFetching = false
            }
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: Error NetworkError.invalidURL - не удалось создать запрос")
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.invalidRequest))
                self.isFetching = false
            }
            return
        }
        print("[ProfileImageService.fetchProfileImageURL]: Статус - отправка запроса. URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                print("[ProfileImageService.fetchProfileImageURL]: Успех - URL аватара получен: \(avatarURL.prefix(20))...")
                
                DispatchQueue.main.async {
                    self.avatarURL = avatarURL
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )
                    completion(.success(avatarURL))
                    self.task = nil
                }
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: Error \(error.localizedDescription) - username: \(username.prefix(6))...")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }
        
        task?.resume()
    }
    
    func cleanAvatarURL() {
        avatarURL = nil
    }
    
    // MARK: - Private Methods
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService.makeProfileImageRequest]: Error - неверный URL для пользователя: \(username.prefix(6))...")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        print("[ProfileImageService.makeProfileImageRequest]: Статус - запрос создан. URL: \(url.absoluteString.prefix(20))...")
        return request
    }
}
