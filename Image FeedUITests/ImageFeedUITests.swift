//
//  ImageFeedUITests.swift
//  Image FeedUITests
//
//  Created by Наталья Черномырдина on 02.06.2025.
//  Тесты

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    //Тестируем кнопку авторизации на главном экране
    func testAuth() throws {
        // Given
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 10), "Не удалось найти кнопку 'Authenticate' на главном экране в течение 10 секунд, возможно не найден WebView с кнопкой")
        
        // When
        authenticateButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10),
                      "Не удалось найти WebView для авторизации в течение 10 секунд")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Не удалось найти поле для ввода логина в течение 10 секунд")
        loginTextField.tap()
        loginTextField.typeText("...")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Не удалось найти поле для ввода пароля в течение 5 секунд")
        passwordTextField.tap()
        UIPasteboard.general.string = "..."
        passwordTextField.doubleTap() //Используем системный буфер обмена для гарантированно точной вставки
        app.menuItems["Paste"].tap()
        webView.swipeUp()
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        
        // Then
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Не удалось загрузить ленту фотографий после авторизации")
    }
    
    //Тестируем таблицу с лентой фотографий
    func testFeed() throws {
        
        // Given
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Основная лента: первая ячейка не загрузилась за 20 секунд")
        
        firstCell.swipeUp()
      
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 10), "Основная лента: не удалось найти вторую ячейку для теста лайков")
        
        // When
        //let likeButton = cellToLike.buttons["photo_like_button"]
        let likeButton = cellToLike.buttons.firstMatch //Временное решение
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Ячейка №1: не найдена кнопка лайка")
        likeButton.tap() // Ставим лайк
        XCTAssertTrue(app.activityIndicators.element.exists, "Индикатор не исчез")
        likeButton.tap() // Убираем лайк
        XCTAssertTrue(app.activityIndicators.element.exists, "Индикатор не исчез")
        
        cellToLike.tap()
        sleep(1)
        
        // Then
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Экран детализации: не загрузилось полноразмерное изображение")
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["back button"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Экран детализации: не найдена кнопка назад")
        backButton.tap()
    }
    
    //Тестируем Профиль и выход из Профиля
    func testProfile() throws {
        // Given
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Не найдена вкладка профиля в TabBar (индекс 1)")
        
        // When
        profileTab.tap()
        
        // Then
        let nameLabel = app.staticTexts["profile_name_label"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Не отображается имя пользователя")
        let loginLabel = app.staticTexts["profile_login_label"]
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5), "Не отображается логин пользователя")
        
        // Given (для логаута)
        let logoutButton = app.buttons["logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Не найдена кнопка выхода")
        
        // When
        logoutButton.tap()
        
        // Then
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Не появилось окно подтверждения выхода")
        
        // When
        let confirmButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3), "Не найдена кнопка подтверждения в алерте")
        confirmButton.tap()
    }
}
