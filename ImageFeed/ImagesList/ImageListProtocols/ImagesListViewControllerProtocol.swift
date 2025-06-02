//
//  ImagesListViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//
import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    
    func showLoading()
    func hideLoading()
    func reloadRows(at indexPaths: [IndexPath])
    func updateTableViewAnimated()
    func getIndexPath(for cell: ImagesListCell) -> IndexPath?
    func showSingleImage(for photo: Photo)
}
