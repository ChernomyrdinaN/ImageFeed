//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//

import Foundation
import UIKit
import WebKit

final class WebViewPresenter: WebViewPresenterProtocol {
    
     weak var view: WebViewViewControllerProtocol?
      
      enum WebViewConstants {
          static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
      }
    
    func viewDidLoad() {
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
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    func didUpdateProgressValue(_ newValue: Double) {
           let newProgressValue = Float(newValue)
           view?.setProgressValue(newProgressValue)
           
           let shouldHideProgress = shouldHideProgress(for: newProgressValue)
           view?.setProgressHidden(shouldHideProgress)
       }
       
       func shouldHideProgress(for value: Float) -> Bool {
           abs(value - 1.0) <= 0.0001
       }
    
    // MARK: - Private Methods
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
