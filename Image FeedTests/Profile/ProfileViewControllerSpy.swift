//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для веб-вью

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    private(set) var updateProfileDetailsCalled = false
    private(set) var showLogoutConfirmationCalled = false
    
    func updateProfileDetails(name: String, login: String, bio: String?) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(with url: URL) {
    }
    func showDefaultProfile() {
    }
    func showLogoutConfirmation(completion: @escaping () -> Void) {
        showLogoutConfirmationCalled = true
    }
    func switchToSplashScreen() {
    }
}
