//
//  ImagesListViewSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для взаимодействия между презентером и вью-контроллером в модуле ImagesList

@testable import ImageFeed
import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var reloadRowsCalled = false
    var showSingleImageCalled = false
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        reloadRowsCalled = true
    }
    
    func getIndexPath(for cell: ImagesListCell) -> IndexPath? {
        return IndexPath(row: 0, section: 0)
    }
    
    func showSingleImage(for photo: Photo) {
        showSingleImageCalled = true
    }
}
