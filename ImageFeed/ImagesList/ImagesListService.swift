//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 16.05.2025.
//

import Foundation

// MARK: - ImagesListService
final class ImagesListService {
    
    // MARK: - Singleton
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private(set) var isFetching = false
    private(set) var lastLoadedPage: Int?
    
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        
        print("[ImagesListService.fetchPhotosNextPage]: Статус - начало загрузки следующей страницы")
        
        guard !isFetching else {
            print("[ImagesListService.fetchPhotosNextPage]: Warning - запрос уже выполняется")
            return
        }
        
        isFetching = true
        task?.cancel()
        print("[ImagesListService.fetchPhotosNextPage]: Статус - предыдущий запрос отменен")
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        print("[ImagesListService.fetchPhotosNextPage]: Статус - загрузка страницы \(nextPage)")
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.fetchPhotosNextPage]: Error ImagesListServiceError.unauthorized - токен отсутствует")
            DispatchQueue.main.async {
                completion(.failure(ImagesListServiceError.unauthorized))
                self.isFetching = false
            }
            return
        }
        
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            print("[ImagesListService.fetchPhotosNextPage]: Error NetworkError.invalidURL - не удалось создать запрос")
            DispatchQueue.main.async {
                completion(.failure(ImagesListServiceError.invalidRequest))
                self.isFetching = false
            }
            return
        }
        
        print("[ImagesListService.fetchPhotosNextPage]: Статус - отправка запроса. URL: \(request.url?.absoluteString.prefix(20) ?? "nil")...")
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map {
                    Photo(from: $0, dateFormatter: self.dateFormatter)
                }
                print("[ImagesListService.fetchPhotosNextPage]: Успех - получено \(newPhotos.count) фотографий")
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion(.success(newPhotos))
                    self.task = nil
                    self.isFetching = false
                }
                
            case .failure(let error):
                if let urlError = error as? URLError,
                   urlError.errorCode == 429 {
                    print("[ImagesListService.fetchPhotosNextPage]: Error 429 - Слишком много запросов. Необходимо снизить частоту обращений.")
                } else {
                    print("[ImagesListService.fetchPhotosNextPage]: Error \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                    self.task = nil
                    self.isFetching = false
                }
            }
        }
        
        task?.resume()
    }
    
    func reset() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
        isFetching = false
        print("[ImagesListService.reset]: Сервис сброшен")
    }
    
    // MARK: - Private Methods
    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        var components = URLComponents(string: "https://api.unsplash.com/photos")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components.url else {
            print("[ImagesListService.makePhotosRequest]: Error - неверный URL для страницы \(page)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        print("[ImagesListService.makePhotosRequest]: Статус - запрос создан. URL: \(url.absoluteString.prefix(20))...")
        return request
    }
}

