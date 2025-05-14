//
//  ViewController.swift
//  ImageFeed
//
//  Created by Наталья Черномырдина on 27.03.2025.
//  Основной экран приложения для просмотра галереи изображений

import UIKit

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
   // private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    // MARK: - IBOutlets
   // @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
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
        tabBarController?.tabBar.barTintColor = Colors.black
        setupTableView()
        setupConstraints()
        
       // tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    // MARK: - UI Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Setup Methods
        private func setupTableView() {
            tableView = UITableView(frame: view.bounds)
            tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.backgroundColor = Colors.black
            view.addSubview(tableView)
        }
     
     private func setupConstraints() {
         tableView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             tableView.topAnchor.constraint(equalTo: view.topAnchor),
             tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }
 }

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Создаем контроллер для просмотра одного изображения
            let singleImageVC = SingleImageViewController()
            
            // Передаем изображение (здесь предполагается, что у вас есть массив изображений)
            singleImageVC.image = UIImage(named: photosName[indexPath.row])
            
            // Показываем контроллер
            present(singleImageVC, animated: true)
            
            // Альтернативный вариант с навигационным контроллером:
            // let navController = UINavigationController(rootViewController: singleImageVC)
            // present(navController, animated: true)
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        return image.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}

// MARK: - Cell Configuration
extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.configure(
            image: UIImage(named: photosName[indexPath.row]),
            date: dateFormatter.string(from: Date()),
            isLiked: indexPath.row % 2 == 0
        )
    }
}
