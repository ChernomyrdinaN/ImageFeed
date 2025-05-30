//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//
import Foundation

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
}
