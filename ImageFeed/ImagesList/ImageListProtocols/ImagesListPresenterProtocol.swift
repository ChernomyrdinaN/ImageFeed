//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//
import Foundation


protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func fetchPhotosNextPage()
    func didTapLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void)
    func photoForIndexPath(_ indexPath: IndexPath) -> Photo?
    func calculateCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
}
