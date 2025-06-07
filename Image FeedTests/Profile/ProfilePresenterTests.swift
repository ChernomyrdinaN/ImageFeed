//
//  ProfilePresenterTests.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тесты

@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    
    //Тестируем загрузку экрана
    func testPresenterCallsViewDidLoad() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        // When
        presenter.viewDidLoad()
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Презентер должен обрабатывать событие viewDidLoad")
    }
    
    //Тестируем загрузку данных профиля и передачу их во View для обновления интерфейса
    func testPresenterUpdatesProfileView() {
        // Given
        let stubService = ProfileServiceStub()
        stubService.testProfile = Profile(
            username: "test",
            name: "Test",
            loginName: "@test",
            bio: nil
        )
        
        let presenter = ProfilePresenter(profileService: stubService)
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewSpy.updateProfileDetailsCalled, "Должен вызываться метод обновления данных вью")
    }
    
    //Проверяем, что презентер реагирует на нажатие кнопки выхода
    func testPresenterHandlesLogoutButtonTap() {
        // Given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(presenter.didTapLogoutCalled, "Презентер должен обрабатывать нажатие кнопки выхода")
    }
    
    //Проверяем,что презентер показывает диалог подтверждения при выходе
    func testPresenterShowsLogoutConfirmation() {
        // Given
        let presenter = ProfilePresenter()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        // When
        presenter.didTapLogout()
        
        // Then
        XCTAssertTrue(viewController.showLogoutConfirmationCalled, "Презентер должен показывать подтверждение выхода")
    }
    
    //Возвращает тестовый профиль при запросе данных
    private class ProfileServiceStub: ProfileServiceProtocol {
        
        var profile: ImageFeed.Profile?
        var testProfile: Profile!
        
        func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
            completion(.success(testProfile))
        }
    }
}
