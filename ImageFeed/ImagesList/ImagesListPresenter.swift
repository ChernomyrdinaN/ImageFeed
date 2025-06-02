//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//

import Foundation
import UIKit
import Kingfisher

// MARK: - ImagesListPresenter
final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private let likeService: LikeServiceProtocol
    private var photos: [Photo] = []
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    // MARK: - Initialization
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared,
         likeService: LikeServiceProtocol = LikeService.shared) {
        self.imagesListService = imagesListService
        self.likeService = likeService
        setupObservers()
        print("[ImagesListPresenter]: Инициализация завершена")
    }
    
    // MARK: - Date Formatters
    private let iso8601Formatter = ISO8601DateFormatter()
    private lazy var displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    // MARK: - Protocol Methods
    
    func viewDidLoad() {
        print("[ImagesListPresenter]: Статус - загрузка представления начата")
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        print("[ImagesListPresenter]: Запрос следующей страницы фото")
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            print("[ImagesListPresenter]: Получен ответ от сервиса")
            switch result {
            case .success:
                print("[ImagesListPresenter]: Успешно загружена новая страница фото")
                self.photos = self.imagesListService.photos
                self.view?.updateTableViewAnimated()
               
            case .failure(let error):
                print("[ImagesListPresenter]: Ошибка загрузки фото - \(error.localizedDescription)")
            }
        }
    }
    
    func changeLike(for cell: ImagesListCell) {
        guard let indexPath = view?.getIndexPath(for: cell),
              indexPath.row < photos.count else {
            print("[ImagesListPresenter]: Не удалось получить indexPath для ячейки")
            return
        }
        
        let photo = photos[indexPath.row]
        view?.showLoading()
        print("[ImagesListPresenter]: Изменение лайка для фото \(photo.id)")
        
        likeService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            self.view?.hideLoading()
            
            switch result {
            case .success:
                print("[ImagesListPresenter]: Лайк успешно изменен")
                self.photos = self.imagesListService.photos
                self.view?.reloadRows(at: [indexPath])
            case .failure(let error):
                print("[ImagesListPresenter]: Ошибка изменения лайка - \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        print("[ImagesListPresenter]: Настройка ячейки для индекса \(indexPath.row)")
        
        // Настройка изображения
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "list_placeholder"),
            options: [.transition(.fade(0.2))]
        )
        
        // Настройка даты
        if let dateString = photo.createdAt,
           let date = iso8601Formatter.date(from: dateString) {
            cell.dateLabel.text = displayDateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        // Настройка лайка
        cell.setIsLiked(photo.isLiked)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        print("[ImagesListPresenter]: Выбрана строка с фото \(photo.id)")
        view?.showSingleImage(for: photo)
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("[ImagesListPresenter]: Достигнут конец списка, загружаем следующую страницу")
            fetchPhotosNextPage()
        }
    }
    
    // MARK: - Private Methods
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            print("[ImagesListPresenter]: Обновление таблицы с анимацией")
            view?.updateTableViewAnimated()
        }
    }
    
    private func setupObservers() {
        print("[ImagesListPresenter]: Настройка наблюдателя для уведомлений")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ImagesListPresenter]: Получено уведомление об изменении фото")
            self?.updateTableViewAnimated()
        }
    }
}
