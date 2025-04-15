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
    
    @IBOutlet weak var progressView: UIProgressView!
    
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
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
        if let code = code(from: navigationAction) { //
            //TODO: process code                     //
            decisionHandler(.cancel) // отменить навигацию
        } else {
            decisionHandler(.allow) // разрешить навигацию
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




