//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//
import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLoadingIndicator(_ show: Bool)
    func showError(_ error: Error)
}
