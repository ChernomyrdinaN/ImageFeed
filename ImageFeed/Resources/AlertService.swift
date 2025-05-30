//
//  AlertService.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 09.05.2025.
//  Сервис для отображения стандартных алертов в приложении

import UIKit

// MARK: - AlertService
@MainActor
final class AlertService {
    
    // MARK: - Public Methods
    static func showErrorAlert(
        on vc: UIViewController,
        title: String = "Что-то пошло не так(",
        message: String = "Не удалось войти в систему",
        buttonTitle: String = "OK"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: buttonTitle, style: .default)
        alert.addAction(okAction)
        
        alert.preferredAction = okAction
        
        vc.present(alert, animated: true)
        
        print("[AlertService] Показан алерт: \(title) - \(message)")
    }
    
    static func showConfirmationAlert(
        on vc: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "Да",
        cancelTitle: String = "Нет",
        confirmHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: confirmTitle, style: .cancel) { _ in
            confirmHandler()
        })
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default))
        
        vc.present(alert, animated: true)
        
        print("[AlertService] Показан алерт подтверждения: \(title) - \(message)")
    }
}
