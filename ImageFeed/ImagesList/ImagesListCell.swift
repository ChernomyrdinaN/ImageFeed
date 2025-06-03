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
    
    // MARK: - Public Properties
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Public Methods
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_on") : UIImage(named: "like_off")
        likeButton.setImage(likeImage, for: .normal)
        likeButton.accessibilityIdentifier = "photo_like_button"
    }
    
    // MARK: - IBActions
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        print("[ImagesListCell.prepareForReuse]: Статус - отмена загрузки и сброс изображения")
    }
}
