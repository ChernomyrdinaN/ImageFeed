//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 01.04.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
