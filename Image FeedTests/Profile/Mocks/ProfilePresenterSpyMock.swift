//
//  ProfilePresenterSpyMock.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для презентера

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpyMock: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private(set) var viewDidLoadCalled = false
    private(set) var didTapLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
