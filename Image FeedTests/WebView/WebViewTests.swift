//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Тесты

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    //Тестируем связь контроллера и презентера: вызов нужных методов презентера при загрузке
    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        //Then
        XCTAssert(presenter.viewDidLoadCalled, "После загрузки экрана должен вызываться viewDidLoad у презентера")
    }
    
    //Тестриуем вызов load(request:) у вьюконтроллера после viewDidLoad() презентера
    func testPresenterCallsLoadRequest () {
        // Given
        let viewControllerSpy = WebViewViewControllerSpyMock()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        presenter.view = viewControllerSpy
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(
            viewControllerSpy.loadRequestCalled, "После viewDidLoad() презентер должен вызвать load(request:) у вью-контроллера"
        )
    }
    
    //Тестируем необходимость скрытия прогресса: значение прогресса меньше 1.0
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertFalse(shouldHideProgress, "Прогресс-бар должен ОТОБРАЖАТЬСЯ, когда значение прогресса (0.6) меньше 1.0")
    }
    
    //Тестируем необходимость скрытия прогресса: значение прогресса равно 1.0
    func testProgressHiddenWhenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //Then
        XCTAssertTrue(shouldHideProgress, "Прогресс-бар должен СКРЫВАТЬСЯ, когда значение прогресса равно 1.0")
    }
    
    //Тестируем хелпер: получение ссылки авторизации authURL
    func testAuthHelperAuthURL() {
        // Given
        let  configuration = AuthConfiguration.standard
        let  authHelper = AuthHelper(configuration: configuration)
        
        // When
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("Не удалось получить строковое представление URL")
            return
        }
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    //Тестируем хелпер: получение кода из URL code(from: URL)
    func testCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        // When
        let code = authHelper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code", "Метод code(from:) должен корректно извлекать значение параметра 'code' из URL")
    }
}
