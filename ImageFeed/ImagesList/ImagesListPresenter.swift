//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.06.2025.
//  Отвечает за бизнес-логику экрана ленты, работая как посредник между View (ImagesListViewController) и сервисами данных

import Foundation
import UIKit
import Kingfisher

// MARK: - ImagesListPresenter
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var numberOfPhotos: Int {
        let count = photos.count
        return count
    }
    private let imagesListService: ImagesListServiceProtocol
    private let likeService: LikeServiceProtocol
    
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
    
    // MARK: - Initialization
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared,
         likeService: LikeServiceProtocol = LikeService.shared) {
        self.imagesListService = imagesListService
        self.likeService = likeService
        print("[ImagesListPresenter.init]: Инициализация сервисов")
        setupObservers()
        print("[ImagesListPresenter]: Инициализация завершена")
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        print("[ImagesListPresenter.viewDidLoad]: Статус - загрузка представления начата")
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        print("[ImagesListPresenter.fetchPhotosNextPage]: Запрос следующей страницы фото")
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self else {
                print("[ImagesListPresenter.fetchPhotosNextPage]: self is nil")
                return
            }
            
            switch result {
            case .success:
                print("[ImagesListPresenter.fetchPhotosNextPage]: Успешно загружена новая страница фото")
                self.photos = self.imagesListService.photos
                self.view?.updateTableViewAnimated()
            case .failure(let error):
                print("[ImagesListPresenter.fetchPhotosNextPage]: Ошибка загрузки фото - \(error.localizedDescription)")
            }
        }
    }
    
    func changeLike(for cell: ImagesListCell) {
        guard let indexPath = view?.getIndexPath(for: cell) else {
            return
        }
        
        guard indexPath.row < photos.count else {
            print("[ImagesListPresenter.changeLike]: Индекс \(indexPath.row) вне диапазона (0..\(photos.count))")
            return
        }
        
        let photo = photos[indexPath.row]
        view?.showLoading()
        print("[ImagesListPresenter.changeLike]: Изменение лайка для фото \(photo.id), текущее состояние: \(photo.isLiked)")
        
        likeService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {
                print("[ImagesListPresenter.changeLike]: self is nil в completion")
                return
            }
            self.view?.hideLoading()
            
            switch result {
            case .success:
                print("[ImagesListPresenter.changeLike]: Лайк успешно изменен для фото \(photo.id)")
                self.photos = self.imagesListService.photos
                print("[ImagesListPresenter.changeLike]: Обновлено состояние лайка: \(self.photos[indexPath.row].isLiked)")
                self.view?.reloadRows(at: [indexPath])
            case .failure(let error):
                print("[ImagesListPresenter.changeLike]: Ошибка изменения лайка - \(error.localizedDescription)")
            }
        }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            print("[ImagesListPresenter.didSelectRow]: Индекс \(indexPath.row) вне диапазона (0..\(photos.count))")
            return
        }
        let photo = photos[indexPath.row]
        print("[ImagesListPresenter.didSelectRow]: Выбрана строка с фото \(photo.id)")
        view?.showSingleImage(for: photo)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("[ImagesListPresenter.willDisplayCell]: Достигнут конец списка, загружаем следующую страницу")
            fetchPhotosNextPage()
        }
    }
    
    // MARK: - Cell Configuration
    @MainActor func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            print("[ImagesListPresenter.configCell]: Индекс \(indexPath.row) вне диапазона (0..\(photos.count))")
            return
        }
        let photo = photos[indexPath.row]
        print("[ImagesListPresenter.configCell]: Настройка ячейки для индекса \(indexPath.row), фото ID: \(photo.id)")
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "list_placeholder"),
            options: [.transition(.fade(0.2))]
        ) { result in
            switch result {
            case .success:
                print("[ImagesListPresenter.configCell]: Изображение успешно загружено для ячейки \(indexPath.row)")
            case .failure(let error):
                print("[ImagesListPresenter.configCell]: Ошибка загрузки изображения: \(error.localizedDescription)")
            }
        }
        
        if let dateString = photo.createdAt,
           let date = iso8601Formatter.date(from: dateString) {
            cell.dateLabel.text = displayDateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        cell.setIsLiked(photo.isLiked)
        print("[ImagesListPresenter.configCell]: Установлено состояние лайка: \(photo.isLiked) для ячейки \(indexPath.row)")
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        guard indexPath.row < photos.count else {
            print("[ImagesListPresenter.heightForRow]: Индекс \(indexPath.row) вне диапазона (0..\(photos.count))")
            return 0
        }
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let height = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return height
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            print("[ImagesListPresenter.updateTableViewAnimated]: Обновление таблицы с анимацией (было: \(oldCount), стало: \(newCount))")
            view?.updateTableViewAnimated()
        } else {
            print("[ImagesListPresenter.updateTableViewAnimated]: Количество фото не изменилось (\(oldCount))")
        }
    }
    // MARK: - Private Methods
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("[ImagesListPresenter.setupObservers]: Получено уведомление об изменении фото")
            self?.updateTableViewAnimated()
        }
    }
}
