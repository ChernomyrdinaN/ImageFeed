//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//

import Foundation
import UIKit
import WebKit

// MARK: - Profile Presenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Dependencies
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    
    // MARK: - Initialization
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
        imageService: ProfileImageServiceProtocol = ProfileImageService.shared){
        self.profileService = profileService
        self.imageService = imageService
    }
    
    // MARK: - Public Methods
        func viewDidLoad() {
            print("[ProfilePresenter.viewDidLoad]: Статус - начало загрузки профиля")
            loadProfile()
        }
        
        func didTapLogout() {
            print("[ProfilePresenter.didTapLogout]: Статус - пользователь нажал выход")
            view?.showLogoutConfirmation { [weak self] in
                self?.performLogout()
            }
        }
        
        // MARK: - Private Methods
        private func loadProfile() {
            print("[ProfilePresenter.loadProfile]: Статус - запрос данных профиля")
            profileService.fetchProfile { [weak self] result in
                switch result {
                case .success(let profile):
                    print("[ProfilePresenter.loadProfile]: Успех - профиль получен: \(profile.name.prefix(10))...")
                    self?.view?.updateProfileDetails(
                        name: profile.name,
                        login: profile.loginName,
                        bio: profile.bio
                    )
                    self?.loadAvatar(username: profile.username)
                case .failure(let error):
                    print("[ProfilePresenter.loadProfile]: Ошибка - \(error.localizedDescription)")
                    self?.view?.showDefaultProfile()
                }
            }
        }
        
        private func loadAvatar(username: String) {
            print("[ProfilePresenter.loadAvatar]: Статус - загрузка аватара для: \(username.prefix(6))...")
            imageService.fetchProfileImageURL(username: username) { [weak self] result in
                switch result {
                case .success(let urlString):
                    print("[ProfilePresenter.loadAvatar]: Успех - URL аватара получен: \(urlString.prefix(20))...")
                    if let url = URL(string: urlString) {
                        self?.view?.updateAvatar(with: url)
                    }
                case .failure(let error):
                    print("[ProfilePresenter.loadAvatar]: Ошибка - \(error.localizedDescription)")
                }
            }
        }
        
        private func performLogout() {
            print("[ProfilePresenter.performLogout]: Статус - выполнение выхода")
            ProfileLogoutService.shared.logout()
            view?.switchToSplashScreen()
        }
    }
