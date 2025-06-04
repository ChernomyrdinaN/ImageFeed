//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для презентера

@testable import ImageFeed
import Foundation

class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
