//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
//  Модель для декодирования JSON из API Unsplash

struct ProfileResult: Codable { // сюда записываем результат получения ответа на запрос
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String? // описание профиля (опционально)
}

private enum CodingKeys: String, CodingKey {
    case username
    case firstName = "first_name"
    case lastName = "last_name"
    case bio
}
