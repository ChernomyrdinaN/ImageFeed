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
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Презентер должен обрабатывать событие viewDidLoad")
    }
    
    //Тестируем загрузку данных профиля и передачу их во View для обновления интерфейса
    func testPresenterUpdatesProfileView() {
        // given
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
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewSpy.updateProfileDetailsCalled, "Должен вызываться метод обновления данных вью")
    }
    
    //Проверяем, что презентер реагирует на нажатие кнопки выхода
    func testPresenterHandlesLogoutButtonTap() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        //when
        presenter.didTapLogout()
        
        //then
        XCTAssertTrue(presenter.didTapLogoutCalled, "Презентер должен обрабатывать нажатие кнопки выхода")
    }
    
    //Проверяем,что презентер показывает диалог подтверждения при выходе
    func testPresenterShowsLogoutConfirmation() {
        //given
        let presenter = ProfilePresenter()
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        
        //when
        presenter.didTapLogout()
        
        //then
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
