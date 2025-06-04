//
//  ProfileViewControllerTests.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//

@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    
    //Тестируем загрузку экрана при вызове configure()
    func testViewControllerConfiguresPresenter() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        
        // when
        viewController.configure(presenter)
        
        // then
        XCTAssertNotNil(viewController.presenter, "Презентер должен быть установлен")
    }
    
    //Проверяем, что при загрузке экрана вызывается загрузка данных через презентер
    func testViewDidLoadTriggersDataLoading() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // when
        viewController.viewDidLoad()
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled, "При загрузке view должен вызываться viewDidLoad презентера")
    }
    
    // Тестируем обновление UI при получении данных
    func testUpdateProfileDetailsChangesUI() {
        // given
        let viewController = ProfileViewController()
        let testName = "Test User"
        let testLogin = "@testuser"
        
        // when
        viewController.updateProfileDetails(name: testName, login: testLogin, bio: nil)
        
        // then
        XCTAssertEqual(viewController.nameLabel.text, testName, "Имя пользователя должно обновляться в UI")
        XCTAssertEqual(viewController.loginLabel.text, testLogin, "Логин пользователя должен обновляться в UI")
    }
    
    //Проверяем, что нажатие на кнопку выхода корректно передается презентеру
    func testLogoutButtonTappedNotifiesPresenter() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        // when
        viewController.didTapLogoutButton()
        
        // then
        XCTAssertTrue(presenter.didTapLogoutCalled, "Нажатие кнопки выхода должно уведомлять презентер")
    }
}
