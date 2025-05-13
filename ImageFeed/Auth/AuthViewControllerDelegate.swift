//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 22.04.2025.
//  Протокол и методы делегата для обработки событий авторизации

// MARK: - AuthViewControllerDelegate Protocol
protocol AuthViewControllerDelegate: AnyObject {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
