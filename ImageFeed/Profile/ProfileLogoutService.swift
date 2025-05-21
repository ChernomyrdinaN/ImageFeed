//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 20.05.2025.
//  Сервис выполняет полный выход пользователя из системы (logout), очищая все данные, связанные с текущей сессией

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        print("[ProfileLogoutService]: Начало процесса выхода")
        cleanCookies()
        cleanAll()
        print("[ProfileLogoutService]: Все данные успешно очищены")
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    private func cleanAll() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatarURL()
        ImagesListService.shared.cleanPhotos()
    }
}
