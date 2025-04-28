//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 13.04.2025.
//  Класс WebViewViewController отвечает за авторизацию OAuth 2.0 в Unsplash

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    weak var delegate: WebViewViewControllerDelegate? // слабая ссылка на делегата, который получит код авторизации
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize" // базовый URL для авторизации через Unsplash OAuth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView() // загружаем страницу авторизации
        updateProgress() // обновляем прогресс-бар
        webView.navigationDelegate = self // устанавливаем делегат для обработки навигиции
    }
    
    override func viewWillAppear(_ animated: Bool) {
        webView.addObserver( // подписываемся/отписываемся от наблюдения за estimatedProgress (прогресс загрузки страницы)
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress() // обновляем прогресс-бар при изменении загрузки
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func updateProgress() { // обновление прогресс-бара
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() { // загрузка страницы авторизации
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { print("Failed to create URLComponents from string: \(WebViewConstants.unsplashAuthorizeURLString)")
            return
        }
        urlComponents.queryItems = [ // формируем URL для OAuth-запроса
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"), // запрашиваем код авторизации (не токен напрямую)
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {print("Failed to create URL from components: \(urlComponents)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebViewViewController: WKNavigationDelegate{  // обработка навигации, если в URL есть код авторизации (code), передаём его делегату и останавливаем загрузку
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel) // отменяем загрузку, т.к. код получен
        } else {
            decisionHandler(.allow) // продолжаем загрузку
        }
    }
}

private func code(from navigationAction: WKNavigationAction) -> String? { // извлекаем OAuth-код авторизации из URL, на который произошёл редирект после успешного входа пользователя через Unsplash OAuth
    if
        let url = navigationAction.request.url,
        let urlComponents = URLComponents(string: url.absoluteString),
        urlComponents.path == "/oauth/authorize/native",
        let items = urlComponents.queryItems,
        let codeItem = items.first(where: { $0.name == "code" })
    {
        return codeItem.value // без этого временного кода нельзя получить токен для доступа к API Unsplash.
    } else {
        return nil
    }
    
}




