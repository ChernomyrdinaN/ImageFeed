//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 19.05.2025.
//

import Foundation

// MARK: - ImagesListCellDelegate Protocol
protocol ImagesListCellDelegate: AnyObject {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
