//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.04.2025.
//  Перечисление ошибок сети

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidResponse
    case tokenDecodingError(Error)
    case apiError(String)
}
