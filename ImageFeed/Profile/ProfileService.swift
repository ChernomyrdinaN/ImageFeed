//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Сервис для работы с профилем пользователя Unsplash

import Foundation

// MARK: - ProfileService
final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    private(set) var isFetching = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if isFetching {
            print("[ProfileService.fetchProfile]: Warning - запрос уже выполняется")
            return
        }
        
        isFetching = true
        print("[ProfileService.fetchProfile]: Статус - запуск запроса профиля")
        
        task?.cancel()
        print("[ProfileService.fetchProfile]: Статус - предыдущий запрос отменен")
        
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileService.fetchProfile]: Error ProfileImageServiceError.unauthorized - токен отсутствует")
            DispatchQueue.main.async {
                completion(.failure(ProfileImageServiceError.unauthorized))
                self.isFetching = false
            }
            return
        }
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: Error NetworkError.invalidURL - токен: \(token.prefix(8))...")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
                self.isFetching = false
            }
            return
        }
        
        print("[ProfileService.fetchProfile]: Статус - отправка запроса. Токен: \(token.prefix(8))...")
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                DispatchQueue.main.async {
                    self.profile = profile
                    completion(.success(profile))
                    self.task = nil
                    self.isFetching = false
                }
                print("[ProfileService.fetchProfile]: Успех - профиль получен. Имя: \(profile.name.prefix(10))...")
                
            case .failure(let error):
                print("[ProfileService.fetchProfile]: Error \(error.localizedDescription) - токен: \(token.prefix(8))...")
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                    self.isFetching = false
                }
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService.makeProfileRequest]: Error - неверный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        print("[ProfileService.makeProfileRequest]: Статус - запрос создан. URL: \(url.absoluteString)")
        return request
    }
}
