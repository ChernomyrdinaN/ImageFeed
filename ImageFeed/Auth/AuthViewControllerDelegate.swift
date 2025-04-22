//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 22.04.2025.
//
protocol AuthViewControllerDelegate: AnyObject {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

