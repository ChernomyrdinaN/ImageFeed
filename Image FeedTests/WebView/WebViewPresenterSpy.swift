//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//  Тестовый двойник (шпион) для презентера 

@testable import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
