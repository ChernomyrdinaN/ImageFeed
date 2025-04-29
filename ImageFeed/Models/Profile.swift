//
//  Profile.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.04.2025.
// Модель для UI Профиль

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String? // описание профиля (опционално)
}

extension Profile {
    init(from result: ProfileResult) { // кастомный инициализатор, создаём и настраиваем новый экземпляр структуры, преобразуем ProfileResult в Profile
        // Берём username как есть
        self.username = result.username
        
        // Формируем name из firstName + lastName (с проверкой на nil)
        let firstName = result.firstName ?? ""  // если nil, подставляем ""
        let lastName = result.lastName ?? ""    // аналогично
        self.name = (firstName + " " + lastName).trimmingCharacters(in: .whitespaces) // удаляет все пробелы и переносы строк с обеих сторон строки
        
        //формируем login, добавляем @ к username
        self.loginName = "@" + result.username
        
        // Копируем bio (оно уже опциональное)
        self.bio = result.bio
    }
}
