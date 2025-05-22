//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.03.2025.
//  Основной экран приложения для просмотра галереи изображений
//

import UIKit
import Kingfisher

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let iso8601Formatter = ISO8601DateFormatter() // проверить
    
    // MARK: - Date Formatter
    private lazy var displayDateFormatter: DateFormatter = { // проверить/хронология
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ImagesListViewController.viewDidLoad]: Статус - начало загрузки данных")
        setupTableView()
        fetchPhotos()
        setupObservers()
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchPhotos() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                print("[ImagesListViewController.fetchPhotos]: Успех - загружена следующая страница")
                self.updateTableViewAnimated()
            case .failure(let error):
                print("[ImagesListViewController.fetchPhotos]: Error - \(error.localizedDescription)")
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        print("[ImagesListViewController.updateTableViewAnimated]: Статус - обновление таблицы")
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            print("[ImagesListViewController.updateTableViewAnimated]: Изменение количества фото: было \(oldCount), стало \(newCount)")
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    private func didTapLikeButton(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        LikeService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            case .failure(let error):
                print("[ImagesListViewController]: Не удалось изменить лайк \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController.prepareForSegue]: Error - неверный destination или sender")
                return
            }
            
            let photo = photos[indexPath.row]
            print("[ImagesListViewController.prepareForSegue]: Статус - переход к фото с URL: \(photo.largeImageURL.prefix(20))...")
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - UI Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("[ImagesListViewController]: Error - не удалось создать ячейку ImagesListCell")
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) { didTapLikeButton(cell)
    }
    
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("[ImagesListViewController]: Статус - выбрана строка \(indexPath.row)")
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("[ImagesListViewController]: Статус - загрузка следующей страницы, достигнут конец списка")
            fetchPhotos()
        }
    }
}

// MARK: - Cell Configuration
extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        print("[ImagesListViewController.configCell]: Статус - конфигурация ячейки для indexPath: \(indexPath)")
        let photo = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "list_placeholder"),
            options: [.transition(.fade(0.2))],
            completionHandler: { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("[ImagesListViewController]: Успешная загрузка для ячейки \(indexPath)")
                    case .failure(let error):
                        print("[ImagesListViewController]: Ошибка в ячейке \(indexPath): \(error.localizedDescription)")
                    }
                }
            }
        )
        
        if let dateString = photo.createdAt,
           let date = iso8601Formatter.date(from: dateString) { // проверить
            cell.dateLabel.text = displayDateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        cell.setIsLiked(photo.isLiked)
    }
}

