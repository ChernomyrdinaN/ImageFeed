//
//  ViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.03.2025.
//  Основной экран приложения для просмотра галереи изображений

import UIKit
import Kingfisher

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesListService.fetchPhotosNextPage { [weak self] _ in
                    self?.tableView.reloadData()
                }
        NotificationCenter.default.addObserver(
                    forName: ImagesListService.didChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    self?.updateTableViewAnimated()
                }
            }
    // MARK: - Private Methods
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
        
    
    // MARK: - Navigation
    override final func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImageSegueIdentifier,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        let photo = photos[indexPath.row]
                guard let url = URL(string: photo.largeImageURL) else { return }
                
                // Исправлено: загрузка полноразмерного изображения через Kingfisher
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let imageResult):
                        viewController.image = imageResult.image
                    case .failure(let error):
                        print("Error loading large image: \(error.localizedDescription)")
                    }
                }
            }
    
    // MARK: - UI Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    final func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    final func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
       final func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           if indexPath.row == photos.count - 1 {
               imagesListService.fetchPhotosNextPage { _ in }
           }
       }
   }

extension ImagesListViewController {
    private final func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.cellImage.kf.indicatorType = .activity
                cell.cellImage.kf.setImage(
                    with: URL(string: photo.thumbImageURL),
                    placeholder: UIImage(named: "loader"), 
                    options: [.transition(.fade(0.2))]
                )
                
                cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let likeImage = photo.isLiked ? UIImage(named: "like_on") : UIImage(named: "like_off")
                cell.likeButton.setImage(likeImage, for: .normal)
    }
}
