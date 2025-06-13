//
//  ProfileViewControllerTests.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тесты

@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    
    //Тестируем загрузку экрана при вызове configure()
    func testViewControllerConfiguresPresenter() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpyMock()
        
        // When
        viewController.configure(presenter)
        
        // Then
        XCTAssertNotNil(viewController.presenter, "Презентер должен быть установлен")
    }
    
    //Проверяем, что при загрузке экрана вызывается загрузка данных через презентер
    func testViewDidLoadTriggersDataLoading() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpyMock()
        viewController.configure(presenter)
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "При загрузке view должен вызываться viewDidLoad презентера")
    }
    
    // Тестируем обновление UI при получении данных
    func testUpdateProfileDetailsChangesUI() {
        // Given
        let viewController = ProfileViewController()
        let testName = "Test User"
        let testLogin = "@testuser"
        
        // When
        viewController.updateProfileDetails(name: testName, login: testLogin, bio: nil)
        
        // Then
        XCTAssertEqual(viewController.nameLabel.text, testName, "Имя пользователя должно обновляться в UI")
        XCTAssertEqual(viewController.loginLabel.text, testLogin, "Логин пользователя должен обновляться в UI")
    }
    
    //Проверяем, что нажатие на кнопку выхода корректно передается презентеру
    func testLogoutButtonTappedNotifiesPresenter() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpyMock()
        viewController.configure(presenter)
        
        // When
        viewController.didTapLogoutButton()
        
        // Then
        XCTAssertTrue(presenter.didTapLogoutCalled, "Нажатие кнопки выхода должно уведомлять презентер")
    }
}
