//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 30.05.2025.
//
//  Презентер для экрана авторизации через WebView

import Foundation
import UIKit
import WebKit

// MARK: - WebViewPresenter
final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    private let authHelper: AuthHelperProtocol
    
    // MARK: - Initialization
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        print("[WebViewPresenter.viewDidLoad]: Статус - инициализация WebView")
        guard let request = authHelper.authRequest() else {
            print("[WebViewPresenter.viewDidLoad]: Ошибка - не удалось создать authRequest")
            return
        }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        print("[WebViewPresenter.didUpdateProgressValue]: Прогресс загрузки - \(newValue)")
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func code(from url: URL) -> String? {
        print("[WebViewPresenter.code]: Попытка извлечь код из URL")
        let code = authHelper.code(from: url)
        if code != nil {
            print("[WebViewPresenter.code]: Успех - код получен")
        } else {
            print("[WebViewPresenter.code]: Ошибка - не удалось извлечь код из URL")
        }
        return code
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}
