//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.03.2025.
//  Класс кастомной ячейки

import UIKit

// MARK: - ImagesListCell
final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        print("[ImagesListCell.prepareForReuse]: Статус - отмена загрузки и сброс изображения")
    }
}
