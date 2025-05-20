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
        cleanCookies()
        cleanToken()
        cleanProfileData()
        cleanProfileImage()
        cleanImagesList()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanProfileData() {
        ProfileService.shared.cleanProfile()
    }
    
    private func cleanProfileImage() {
        ProfileImageService.shared.cleanAvatarURL()
    }
    
    private func cleanImagesList() {
        ImagesListService.shared.cleanPhotos()
    }
}
