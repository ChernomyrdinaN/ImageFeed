//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.04.2025.
//  ViewController для просмотра и масштабирования единичного изображения

import UIKit
import Kingfisher

// MARK: - SingleImageViewController
final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    var fullImageURL: URL?
    
    // MARK: - IBOutlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
        loadImage()
    }
    
    // MARK: - Public Methods
    func rescaleAndCenterImageInScrollView(image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let boundsZoom = scrollView.bounds.size
        let contentZoom = scrollView.contentSize
        let horizontal = max(0, boundsZoom.width - contentZoom.width) / 2
        let vertical = max(0, boundsZoom.height - contentZoom.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    // MARK: - Private Methods
    private func configureScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    // MARK: - Private Methods
    private func loadImage() {
        guard let url = fullImageURL else {
            print("[SingleImageViewController.loadImage]: Error - URL изображения отсутствует")
            return
        }
        
        print("[SingleImageViewController.loadImage]: Статус - начало загрузки изображения. URL: \(url.absoluteString.prefix(20))...")
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "single_loader"),
            options: [.transition(.fade(0.2))],
            completionHandler: { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    
                    switch result {
                    case .success(let imageResult):
                        print("[SingleImageViewController.loadImage]: Успех - изображение загружено")
                        self?.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    case .failure(let error):
                        print("[SingleImageViewController.loadImage]: Ошибка загрузки: \(error.localizedDescription)")
                        self?.showError()
                    }
                }
            }
        )
    }
    
    private func showError() {
        AlertService.showErrorAlert(
            on: self,
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            buttonTitle: "Не надо"
        ) { [weak self] in
            self?.retryLoadImage()
        }
    }
    
    private func retryLoadImage() {
        loadImage()
    }
    
    // MARK: - IBActions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
