//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var numberOfPhotos: Int { get }
    
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(for cell: ImagesListCell)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    func willDisplayCell(at indexPath: IndexPath)
}
