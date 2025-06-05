//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//  Протокол вью для взаимодействия с презентером

import Foundation

// MARK: - WebViewViewControllerProtocol
public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
