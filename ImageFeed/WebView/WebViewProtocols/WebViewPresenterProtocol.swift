//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//  Протокол презентера для экрана веб-авторизации

import Foundation

// MARK: - WebViewPresenterProtocol
public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}
