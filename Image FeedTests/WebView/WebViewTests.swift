//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Наталья Черномырдина on 31.05.2025.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    //Тестируем связь контроллера и презентера: вызов нужных методов презентера при загрузке
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssert(presenter.viewDidLoadCalled,
                  "После загрузки экрана должен вызываться viewDidLoad у презентера")
    }
    
    //Тестриуем вызов load(request:) у вьюконтроллера после viewDidLoad() презентера
    func testPresenterCallsLoadRequest () {
        //given
        let viewControllerSpy = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        presenter.view = viewControllerSpy
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(
            viewControllerSpy.loadRequestCalled,
            "После viewDidLoad() презентер должен вызвать load(request:) у вью-контроллера"
        )
    }
    
    //Тестируем необходимость скрытия прогресса: значение прогресса меньше 1.0
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(
            shouldHideProgress,
            "Прогресс-бар должен ОТОБРАЖАТЬСЯ, когда значение прогресса (0.6) меньше 1.0"
        )
    }
    
    //Тестируем необходимость скрытия прогресса: значение прогресса равно 1.0
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(
            shouldHideProgress,
            "Прогресс-бар должен СКРЫВАТЬСЯ, когда значение прогресса равно 1.0"
        )
    }
    
    //Тестируем хелпер: получение ссылки авторизации authURL
    func testAuthHelperAuthURL() {
        //given
        let  configuration = AuthConfiguration.standard
        let  authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("Не удалось получить строковое представление URL")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    //Тестируем хелпер: получение кода из URL code(from: URL)
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(
            code,
            "test code",
            "Метод code(from:) должен корректно извлекать значение параметра 'code' из URL"
        )
    }
}
