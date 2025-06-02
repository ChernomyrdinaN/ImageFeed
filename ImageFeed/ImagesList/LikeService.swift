//
//  LikeService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.05.2025.
//  Сервис для работы с лайками фотографий

import Foundation

// MARK: - LikeService
final class LikeService {
    
    // MARK: - Singleton
    static let shared = LikeService()
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var isFetching = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        print("[LikeService.changeLike]: Статус - начало обработки лайка для photoId: \(photoId), isLike: \(isLike)")
        
        guard !isFetching else {
            print("[LikeService.changeLike]: Warning - запрос уже выполняется")
            return
        }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[LikeService.changeLike]: Error - токен отсутствует")
            DispatchQueue.main.async {
                completion(.failure(LikeServiceError.unauthorized))
            }
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            print("[LikeService.changeLike]: Error - неверный запрос")
            DispatchQueue.main.async {
                completion(.failure(LikeServiceError.invalidRequest))
            }
            return
        }
        
        print("[LikeService.changeLike]: Статус - отправка запроса. Метод: \(request.httpMethod ?? ""), URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
        
        isFetching = true
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
            
            if let error {
                print("[LikeService.changeLike]: Error - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[LikeService.changeLike]: Error - неверный ответ сервера")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("[LikeService.changeLike]: Error - сервер вернул код \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }
            
            DispatchQueue.main.async {
                ImagesListService.shared.updatePhotoLike(photoId: photoId, isLiked: isLike)
                print("[LikeService.changeLike]: Данные обновлены в ImagesListService")
            }
            print("[LikeService.changeLike]: Успех - лайк изменен для photoId: \(photoId)")
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        
        task?.resume()
    }
    
    // MARK: - Private Methods
    private func makeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("[LikeService.makeLikeRequest]: Error - неверный URL для photoId: \(photoId)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        return request
    }
    
    // MARK: - Helper Methods
    func cancelCurrentTask() {
        task?.cancel()
        isFetching = false
        print("[LikeService.cancelCurrentTask]: Статус - текущий запрос отменен")
    }
}
extension LikeService: LikeServiceProtocol {}
