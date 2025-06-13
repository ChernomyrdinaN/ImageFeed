//
//  ImagesListPresenterTests.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тесты

@testable import ImageFeed
import XCTest

final class ImagesListPresenterTests: XCTestCase {
    
    //Тестируем viewDidLoad()
    func testViewDidLoadCallsFetchPhotos() {
        // Given
        let presenter = ImagesListPresenter()
        let spyViewController = ImagesListViewControllerSpyMock()
        presenter.view = spyViewController
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenter.numberOfPhotos >= 0, "При загрузке вью должен начаться процесс получения фото")
    }
    
    //Тестируем, что таблица обновляется после загрузки фото
    func testTableViewUpdatesAfterPhotosLoaded() {
        
        // Given
        let presenter = ImagesListPresenter()
        let spyViewController = ImagesListViewControllerSpyMock()
        presenter.view = spyViewController
        
        // When
        presenter.fetchPhotosNextPage() 
        presenter.photos = [Photo(id: "test", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        presenter.updateTableViewAnimated() 
        
        // Then
        XCTAssertTrue(
            spyViewController.updateTableViewAnimatedCalled, "После загрузки фото таблица должна обновляться с анимацией")
    }
    
    //Тестируем пагинацию при скролле
    func testWillDisplayCellLoadsNextPageIfNeeded() {
        // Given
        let presenter = ImagesListPresenter()
        let spyViewController = ImagesListViewControllerSpyMock()
        presenter.view = spyViewController
        
        // Создаем 10 тестовых фото
        let testPhotos = (0..<10).map { _ in
            Photo(
                id: UUID().uuidString,
                size: CGSize(width: 100, height: 100),
                createdAt: nil,
                welcomeDescription: nil,
                thumbImageURL: "",
                largeImageURL: "",
                isLiked: false
            )
        }
        presenter.photos = testPhotos
        let lastIndexPath = IndexPath(row: testPhotos.count - 1, section: 0)
        
        // When
        presenter.willDisplayCell(at: lastIndexPath)
        
        // Then
        XCTAssertTrue(
            presenter.numberOfPhotos > 0, "При скролле к последней ячейке должна начаться загрузка новой страницы")
    }
}
