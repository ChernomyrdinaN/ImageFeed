//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Наталья Черномырдина on 02.06.2025.
//

//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Наталья Черномырдина on 02.06.2025.
//
import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    // MARK: - Тест авторизации
     func testAuth() throws {
     // Шаг 1: Нажатие кнопки авторизации на главном экране
     let authenticateButton = app.buttons["Authenticate"]
     XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5),
     "Не удалось найти кнопку 'Authenticate' на главном экране в течение 5 секунд, возможно не найден WebView с кнопкой")
     authenticateButton.tap()
     
     // Шаг 2: Проверка наличия WebView для авторизации
     let webView = app.webViews["UnsplashWebView"]
     XCTAssertTrue(webView.waitForExistence(timeout: 5),
     "Не удалось найти WebView для авторизации в течение 5 секунд")
     
     // Шаг 3: Поиск и заполнение поля логина
     let loginTextField = webView.descendants(matching: .textField).element
     XCTAssertTrue(loginTextField.waitForExistence(timeout: 5),
     "Не удалось найти поле для ввода логина в течение 5 секунд")
     
     // Ввод логина
     loginTextField.tap()
     loginTextField.typeText("...")
     webView.swipeUp()
     
     // Шаг 4: Поиск и заполнение поля пароля
     let passwordTextField = webView.descendants(matching: .secureTextField).element
     XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5),
     "Не удалось найти поле для ввода пароля в течение 5 секунд")
     
     /*
      Особое внимание: Ввод пароля через буфер обмена
      - Проблема: Прямой ввод пароля через typeText() может приводить к пропуску символов
      - Решение: Используем системный буфер обмена для гарантированно точной вставки
      */
     passwordTextField.tap()
     UIPasteboard.general.string = "...."
     passwordTextField.doubleTap()
     app.menuItems["Paste"].tap()
     webView.swipeUp()
     
     // Шаг 5: Нажатие кнопки входа
     webView.buttons["Login"].tap()
     
     // Шаг 6: Проверка успешной авторизации (показ ленты)
     let tablesQuery = app.tables
     let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
     XCTAssertTrue(cell.waitForExistence(timeout: 5),
     "Не удалось загрузить ленту фотографий после авторизации")
     }
     // MARK: - Тест ленты и лайка
     func testFeed() throws {
     // Шаг 1: Получаем таблицу с лентой фотографий
     let tablesQuery = app.tables
     
     // Шаг 2: Проверяем загрузку первой ячейки и делаем скролл
     let firstCell = tablesQuery.cells.element(boundBy: 0)
     XCTAssertTrue(firstCell.waitForExistence(timeout: 5),
     "Основная лента: первая ячейка не загрузилась за 5 секунд")
     firstCell.swipeUp() // Имитируем скролл для активации загрузки
     sleep(1) // Краткая пауза для стабилизации UI
     
     // Шаг 3: Находим ячейку для тестирования лайков
     let cellToLike = tablesQuery.cells.element(boundBy: 1)
     XCTAssertTrue(cellToLike.waitForExistence(timeout: 5),
     "Основная лента: не удалось найти вторую ячейку для теста лайков")
     
     // Шаг 4: Работа с кнопкой лайка
     //let likeButton = cellToLike.buttons.firstMatch // Временное решение
     let likeButton = cellToLike.buttons["photo_like_button"]
     XCTAssertTrue(likeButton.waitForExistence(timeout: 3),
     "Ячейка №1: не найдена кнопка лайка")
     
     // Тестируем toggle лайка
     likeButton.tap() // Ставим лайк
     XCTAssertFalse(app.activityIndicators.element.exists, "Анимация все еще выполняется")
     likeButton.tap() // Убираем лайк
     XCTAssertFalse(app.activityIndicators.element.exists, "Анимация все еще выполняется")
     
     // Шаг 5: Переход на экран детализации
     cellToLike.tap() // Тап по ячейке для перехода
     XCTAssertFalse(app.activityIndicators.element.exists, "Анимация все еще выполняется")
     
     // Шаг 6: Проверка полноразмерного изображения
     let image = app.scrollViews.images.element(boundBy: 0)
     XCTAssertTrue(image.waitForExistence(timeout: 5),
     "Экран детализации: не загрузилось полноразмерное изображение")
     
     // Шаг 7: Тест жестов масштабирования
     image.pinch(withScale: 3, velocity: 1) // Zoom in
     image.pinch(withScale: 0.5, velocity: -1) // Zoom out
     
     // Шаг 8: Возврат на предыдущий экран
     let backButton = app.buttons["nav_button_back"]
     XCTAssertTrue(backButton.waitForExistence(timeout: 5),
     "Экран детализации: не найдена кнопка назад")
     backButton.tap()
     }
    
    // MARK: - Тест профиля и выхода
    func testProfile() throws {
        // Шаг 1: Ожидание загрузки интерфейса
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 3))
        
        // Шаг 2: Переход на вкладку профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5),
                      "Не найдена вкладка профиля в TabBar (индекс 1)")
        profileTab.tap()
        
        // Шаг 3: Проверка отображения данных профиля
        let nameLabel = app.staticTexts["profile_name_label"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5),
                      "Не отображается имя пользователя")
        
        let loginLabel = app.staticTexts["profile_login_label"]
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5),
                      "Не отображается логин пользователя")
        
        // Шаг 4: Выход из профиля
        let logoutButton = app.buttons["logout_button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5),
                      "Не найдена кнопка выхода")
        logoutButton.tap()
        
        // Шаг 5: Подтверждение выхода
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3),
                      "Не появилось окно подтверждения выхода")
        
        let confirmButton = alert.scrollViews.otherElements.buttons["Да"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3),
                      "Не найдена кнопка подтверждения в алерте")
        confirmButton.tap()
    }
}
