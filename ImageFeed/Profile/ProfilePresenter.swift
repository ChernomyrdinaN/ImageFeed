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
        loadProfile()
    }
    
    func didTapLogout() {  
        view?.showLogoutConfirmation { [weak self] in
            self?.performLogout()
        }
    }
    
    // MARK: - Private Methods
    private func loadProfile() {
        profileService.fetchProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.view?.updateProfileDetails(
                    name: profile.name,
                    login: profile.loginName,
                    bio: profile.bio
                )
                self?.loadAvatar(username: profile.username)
            case .failure:
                self?.view?.showDefaultProfile()
            }
        }
    }
    
    private func loadAvatar(username: String) {
        imageService.fetchProfileImageURL(username: username) { [weak self] result in
            if case .success(let urlString) = result, let url = URL(string: urlString) {
                self?.view?.updateAvatar(with: url)
            }
        }
    }
    
    private func performLogout() {
        ProfileLogoutService.shared.logout()
        view?.switchToSplashScreen()
    }
}
