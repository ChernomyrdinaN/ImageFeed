//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Сервис для получения профиля пользователя Unsplash
//
import Foundation

final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.unauthorized))
            }
            return
        }
        
        guard let request = makeProfileRequest(token: token) else {
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.invalidRequest))
            }
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                DispatchQueue.main.async {
                    self.profile = profile
                    completion(.success(profile))
                    self.task = nil
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                }
            }
        }
        
        task?.resume()
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
}
