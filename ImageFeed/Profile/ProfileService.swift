//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//
import Foundation

final class ProfileService {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
    }
    
    private func makeProfileRequest(code: String) -> URLRequest { // вспомогательный метод для создания URLRequest для получения профиля пользователя
        // создаем url
        guard let url = URL(string: "https://unsplash.com/me") else { //официальный endpoint Unsplash API
            fatalError("Failed to create URL")
        }
        // создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // добавляем заголовки
        request.setValue("Bearer \(code)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version") // версия API Unsplash
        
        request.timeoutInterval = 30 // если сервер не отвечает, запрос отмениться
        
        return request
    }
}
