//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 13.04.2025.
//  Класс WebViewViewController отвечает за авторизацию OAuth 2.0 в Unsplash

import UIKit
import WebKit

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol{
    
    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - IBOutlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[WebViewViewController.viewDidLoad]: Статус - инициализация WebView")
        webView.accessibilityIdentifier = "UnsplashWebView" // для тестирования
        presenter?.viewDidLoad()
        
        webView.navigationDelegate = self
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 print("[WebViewViewController.observe]: Прогресс загрузки - \(webView.estimatedProgress)")
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    // MARK: - Public Methods
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        print("[WebViewViewController.load]: Загрузка запроса - \(request.url?.absoluteString.prefix(30) ?? "unknown")...")
        webView.load(request)
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            print("[WebViewViewController.code]: Анализ URL для извлечения кода - \(url.absoluteString.prefix(30))...")
            return presenter?.code(from: url)
        }
        print("[WebViewViewController.code]: Ошибка - не удалось получить URL из navigationAction")
        return nil
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate{
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            print("[WebViewViewController.decidePolicyFor]: Успешная аутентификация, код получен")
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            print("[WebViewViewController.decidePolicyFor]: Продолжение навигации")
            decisionHandler(.allow)
        }
    }
}
