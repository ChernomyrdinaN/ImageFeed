//
//  ImagesListViewSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для взаимодействия между презентером и вью-контроллером в модуле ImagesList

@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    private(set) var updateTableViewAnimatedCalled = false
    private(set) var showLoadingCalled = false
    private(set) var hideLoadingCalled = false
    private(set) var reloadRowsCalled = false
    private(set) var showSingleImageCalled = false
    
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
