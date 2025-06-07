//
//  ImagesListViewControllerTests.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тесты

@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    
    //Тестируем настройку таблицы при загрузке вью
    func testViewDidLoadSetsTableView() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        
        // When
        viewController.loadViewIfNeeded() 
        
        // Then
        XCTAssertNotNil( viewController.tableView.dataSource, "После загрузки view должен быть установлен dataSource таблицы"
        )
        XCTAssertNotNil( viewController.tableView.delegate, "После загрузки view должен быть установлен delegate таблицы"
        )
    }
    
    // Тетируем количество строк в таблице
    func testTableViewReturnsCorrectNumberOfRows() {
        // Given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        presenterSpy.numberOfPhotos = 5
        viewController.configure(presenterSpy)
        
        // When
        let rowsCount = viewController.tableView(
            UITableView(),
            numberOfRowsInSection: 0
        )
        
        // Then
        XCTAssertEqual(rowsCount, 5, "Количество строк должно совпадать с numberOfPhotos презентера")
    }
    
    //Тестируем бработку нажатия лайка
    func testLikeButtonTappedNotifiesPresenter() {
        // Given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        let testCell = ImagesListCell()
        
        // When
        viewController.imageListCellDidTapLike(testCell)
        
        // Then
        XCTAssertTrue(presenterSpy.changeLikeCalled, "Нажатие на лайк должно вызывать changeLike у презентера")
    }
}
