//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.05.2025.
//  Cервис для получения URL аватарки пользователя
//
import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: ProfileImageServiceError.unauthorized - username: \(username), token: nil")
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.unauthorized))
            }
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError.invalidURL - username: \(username)")
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.invalidRequest))
            }
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let userResult):
                let avatarURL = userResult.profileImage.small
                
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
                print("[ProfileImageService.fetchProfileImageURL]: \(error) - username: \(username)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }
        
        task?.resume()
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
}
