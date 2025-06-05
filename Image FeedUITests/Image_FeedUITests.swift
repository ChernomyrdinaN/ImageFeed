//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Наталья Черномырдина on 02.06.2025.
//  Тесты

import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    //Тестируем кнопку авторизации на главном экране
    func testAuth() throws {
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5), "Не удалось найти кнопку 'Authenticate' на главном экране в течение 5 секунд, возможно не найден WebView с кнопкой")
        authenticateButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5),
                      "Не удалось найти WebView для авторизации в течение 5 секунд")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Не удалось найти поле для ввода логина в течение 5 секунд")
        
        loginTextField.tap()
        loginTextField.typeText("...")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Не удалось найти поле для ввода пароля в течение 5 секунд")
        
        passwordTextField.tap()
        UIPasteboard.general.string = "..."
        passwordTextField.doubleTap() // Используем системный буфер обмена для гарантированно точной вставки
        app.menuItems["Paste"].tap()
        webView.swipeUp()
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Не удалось загрузить ленту фотографий после авторизации")
    }
    
    //Тестируем таблицу с лентой фотографий
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Основная лента: первая ячейка не загрузилась за 10 секунд")
        firstCell.swipeUp()
        sleep(1)
        
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Основная лента: не удалось найти вторую ячейку для теста лайков")
        
        let likeButton = cellToLike.buttons.firstMatch // Временное решение
        //let likeButton = cellToLike.buttons["photo_like_button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3), "Ячейка №1: не найдена кнопка лайка")
        
        likeButton.tap() // Ставим лайк
        XCTAssertTrue(app.activityIndicators.element.exists, "Индикатор не исчез")
        likeButton.tap() // Убираем лайк
        XCTAssertTrue(app.activityIndicators.element.exists, "Индикатор не исчез")
        
        if !cellToLike.isHittable {
            app.swipeUp()
        }
        cellToLike.tap()
        
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
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Не найдена вкладка профиля в TabBar (индекс 1)")
        profileTab.tap()
        
        let nameLabel = app.staticTexts["profile_name_label"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Не отображается имя пользователя")
        
        let loginLabel = app.staticTexts["profile_login_label"]
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5), "Не отображается логин пользователя")
        
        let logoutButton = app.buttons["logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Не найдена кнопка выхода")
        logoutButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Не появилось окно подтверждения выхода")
        
        let confirmButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3), "Не найдена кнопка подтверждения в алерте")
        confirmButton.tap()
    }
}
