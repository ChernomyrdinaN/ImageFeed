//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 31.05.2025.
//
import Foundation

// MARK: - Profile Presenter Protocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
}
