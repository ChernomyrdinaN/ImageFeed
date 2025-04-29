//
//  Untitled.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 15.04.2025.
//  Протокол и методы делегата для обработки событий авторизации

protocol WebViewViewControllerDelegate: AnyObject {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
