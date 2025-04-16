//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 13.04.2025.
//
import UIKit
@preconcurrency import WebKit

final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate? //добавим слабую ссылку на делегата
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    override func viewDidLoad() { // один раз после загрузки view в память.
        super.viewDidLoad()
        loadAuthView()
        updateProgress()
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) { // перед показом экрана, добавляем наблюдателя за прогрессом нагрузки
        webView.addObserver(
            self, // кто наблюдает
            forKeyPath: #keyPath(WKWebView.estimatedProgress), // за каким свойством
            options: .new, // хотим получать новое значение
            context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) { // перед исчезновением view (например, при переходе на другой экран), даление наблюдателя в ЖЦ
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    override func observeValue( // обработчик изменения estimatedProgress
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { print("Failed to create URLComponents from string: \(WebViewConstants.unsplashAuthorizeURLString)")
            return
        }
        urlComponents.queryItems = [ // настройка запроса, компоненты по протоколу Unsplash
            URLQueryItem(name: "client_id", value: Constants.accessKey), // код доступа
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI), // uri успешной авторизации
            URLQueryItem(name: "response_type", value: "code"), // тип ответа
            URLQueryItem(name: "scope", value: Constants.accessScope) // список доступов
        ]
        guard let url = urlComponents.url else {print("Failed to create URL from components: \(urlComponents)")
            return
        }
        let request = URLRequest(url: url) // формируем и передаем ответ в вебью для загрузки
        webView.load(request)
    }
}
  
extension WebViewViewController: WKNavigationDelegate{
    func webView( // метод возвращает код авторизации
        _ webView: WKWebView, // делегат может принимать сообщения от разных вью
        decidePolicyFor navigationAction: WKNavigationAction, // из за чего произошли навигационные действия
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void // замыкание
    ) {
        if let code = code(from: navigationAction) { // если код извлекли(OAuth-токен или код подтверждения) не nil
            //TODO: process code  delegate?.webViewViewController(self, didAuthenticateWithCode: code) // уведомляет делегата об этом
            decisionHandler(.cancel) // отменить навигацию, запрещает переход по URL, так как код уже извлечён
        } else {
            decisionHandler(.allow) // разрешить навигацию, если код не извлекли, WebView продолжит навигацию как обычно
        }
    }
}
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         // получили URL
            let urlComponents = URLComponents(string: url.absoluteString),  // получаем значение компонентов из URL
            urlComponents.path == "/oauth/authorize/native",                // сверка адресов
            let items = urlComponents.queryItems,                           // проверка самого запроса
            let codeItem = items.first(where: { $0.name == "code" })        // ищем компонент
        {
            return codeItem.value                                           //если проверки все успешны возвращаем значение
        } else {
            return nil
    }
}




