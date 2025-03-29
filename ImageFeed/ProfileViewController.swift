//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 29.03.2025.
//
import UIKit

final class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutTapped(_ sender: Any) {
    }
}
