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
    
    // MARK: - UI Elements
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    private var presenter: ImagesListPresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ImagesListViewController.viewDidLoad]: Статус - инициализация экрана")
        
        if presenter == nil {
            configure(ImagesListPresenter())
        }
        setupTableView()
        presenter.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Configuration
    func configure(_ presenter: ImagesListPresenterProtocol) {
        print("[ImagesListViewController.configure]: Статус - настройка презентера")
        self.presenter = presenter
        presenter.view = self
        print("[ImagesListViewController.configure]: Presenter.view установлен? \(presenter.view != nil)")
    }
    
    private func setupTableView() {
        print("[ImagesListViewController.setupTableView]: Статус - настройка таблицы")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage",
           let viewController = segue.destination as? SingleImageViewController,
           let photo = sender as? Photo {
            print("[ImagesListViewController.prepare]: Подготовка перехода к деталям фото")
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        }
    }
}

// MARK: - ImagesListViewControllerProtocol
extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableViewAnimated() {
        guard presenter.numberOfPhotos > 0 else {
            print("[ImagesListViewController.updateTableViewAnimated]: Нет данных для отображения")
            return
        }
        
        tableView.performBatchUpdates {
            let oldCount = tableView.numberOfRows(inSection: 0)
            let newCount = presenter.numberOfPhotos
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
        }
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        print("[ImagesListViewController.reloadRows]: Обновление строк \(indexPaths)")
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func getIndexPath(for cell: ImagesListCell) -> IndexPath? {
        let indexPath = tableView.indexPath(for: cell)
        print("[ImagesListViewController.getIndexPath]: Получен indexPath для ячейки - \(String(describing: indexPath))")
        return indexPath
    }
    
    func showSingleImage(for photo: Photo) {
        print("[ImagesListViewController.showSingleImage]: Показать детали фото \(photo.id)")
        performSegue(withIdentifier: "ShowSingleImage", sender: photo)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = presenter.numberOfPhotos
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("[ImagesListViewController.tableView.cellForRowAt]: Создание ячейки для indexPath - \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("[ImagesListViewController.tableView.cellForRowAt]: Ошибка создания ячейки ImagesListCell")
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        presenter.configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = presenter.heightForRow(at: indexPath, tableViewWidth: tableView.bounds.width)
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        print("[ImagesListViewController.imageListCellDidTapLike]: Обработка нажатия лайка в ячейке")
        presenter.changeLike(for: cell)
    }
}
