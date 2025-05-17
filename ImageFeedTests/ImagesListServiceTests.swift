//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Наталья Черномырдина on 17.05.2025.
//  Тест ждёт нотификации didChangeNotification, которая должна прийти после успешной загрузки фото.

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage { result in
            switch result {
            case .success(let photos):
                print("Успешно загружено \(photos.count) фото")
            case .failure(let error):
                XCTFail("Ошибка загрузки: \(error)")
            }
        }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        service.fetchPhotosNextPage { result in
            switch result {
            case .success(let photos):
                print("Успешно грузится вторая страница \(photos.count) фото")
            case .failure(let error):
                XCTFail("Ошибка загрузки: \(error)")
            }
        }
    }
}
