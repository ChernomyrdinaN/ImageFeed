//
//  AlertService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 09.05.2025.
//  Сервис для отображения стандартных алертов в приложении

import UIKit

// MARK: - AlertService
@MainActor  // Гарантирует выполнение на главном потоке
final class AlertService {
    
    // MARK: - Public Methods
    static func showErrorAlert(
        on vc: UIViewController,
        title: String = "Что-то пошло не так(",
        message: String = "Не удалось выполнить операцию",
        buttonTitle: String = "OK",
        retryHandler: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        
        if let retryHandler {
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
                retryHandler()
            })
        }
        
        vc.present(alert, animated: true)
        
        print("[AlertService] Показан алерт: \(title) - \(message)")
    }
}
