//
//  Untitled.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 15.04.2025.
//
protocol WebViewViewControllerDelegate: AnyObject { // определим протокол и методы делегата
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) //WebViewViewController получил код
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) //пользователь нажал кнопку назад и отменил авторизацию
}

