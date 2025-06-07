//
//  WebViewViewControllerSpyMock.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Тестовый двойник (шпион) для веб-вью

@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpyMock: WebViewViewControllerProtocol {
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    
    var loadRequestCalled = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
