//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 04.06.2025.
//  Тестовый двойник (шпион) для взаимодействия между презентером и вью-контроллером

@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var numberOfPhotos: Int = 0
    private(set) var viewDidLoadCalled = false
    private(set) var fetchPhotosNextPageCalled = false
    private(set) var changeLikeCalled = false
    private(set) var configCellCalled = false
    private(set) var didSelectRowCalled = false
    private(set) var heightForRowCalled = false
    private(set) var willDisplayCellCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(for cell: ImagesListCell) {
        changeLikeCalled = true
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        configCellCalled = true
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        didSelectRowCalled = true
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        heightForRowCalled = true
        return 100
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalled = true
    }
}
