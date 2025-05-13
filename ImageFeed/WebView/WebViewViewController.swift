//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 13.04.2025.
//  Класс WebViewViewController отвечает за авторизацию OAuth 2.0 в Unsplash

import UIKit
import WebKit

// MARK: - WebViewViewController
final class WebViewViewController: UIViewController {
    
    // MARK: - Constants
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    // MARK: - Properties
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = Colors.black
        return webView
    } ()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = Colors.white
        progressView.trackTintColor = Colors.gray
        return progressView
        
    } ()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.black
        setupViews()
        setupConstraints()
        
        loadAuthView()
        updateProgress()
        
        
        webView.navigationDelegate = self
        setupProgressObserver()
        
        configureBackButton()
    }
    
    // MARK: - Private Methods
        private func setupViews() {
                [webView, progressView].forEach {
                    $0.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview($0)
                }
            }

        // макеты уточнить
          private func setupConstraints() {
              NSLayoutConstraint.activate([
                  // WebView занимает весь экран
                  webView.topAnchor.constraint(equalTo: view.topAnchor),
                  webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                  
                  // ProgressView под navigation bar
                  progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                  progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  progressView.heightAnchor.constraint(equalToConstant: 2)
              ])
          }
        
        private func setupProgressObserver() {
               estimatedProgressObservation = webView.observe(
                   \.estimatedProgress,
                   options: [],
                   changeHandler: { [weak self] _, _ in
                       guard let self = self else { return }
                       self.updateProgress()
                   })
           }
        
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { print("Failed to create URLComponents from string: \(WebViewConstants.unsplashAuthorizeURLString)")
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else {print("Failed to create URL from components: \(urlComponents)")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    private func code(from navigationAction: WKNavigationAction) -> String? {
            if let url = navigationAction.request.url,
               let urlComponents = URLComponents(string: url.absoluteString),
               urlComponents.path == "/oauth/authorize/native",
               let items = urlComponents.queryItems,
               let codeItem = items.first(where: { $0.name == "code" }) {
                return codeItem.value
            }
            return nil
        }
    
        // Настройка кнопки "Назад" (аналогично AuthViewController)
        private func configureBackButton() {
                navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
                navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
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
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}


