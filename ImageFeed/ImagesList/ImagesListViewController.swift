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
final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - UI Elements
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Properties
    private var presenter: ImagesListPresenterProtocol!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ImagesListViewController]: Статус - инициализация экрана")
        
        if presenter == nil {
            configure(ImagesListPresenter())
        }
        setupTableView()
        presenter.viewDidLoad()
    }
    
    // MARK: - Configuration
    func configure(_ presenter: ImagesListPresenterProtocol) {
        print("[ImagesListViewController]: Статус - настройка презентера")
        self.presenter = presenter
        presenter.view = self
        print("[ImagesListViewController]: Presenter.view установлен? \(presenter.view != nil)")
    }
    
    private func setupTableView() {
        print("[ImagesListViewController]: Статус - настройка таблицы")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - ImagesListViewControllerProtocol
    func updateTableViewAnimated() {
        print("[ImagesListViewController]: Анимированное обновление таблицы")
        print("Текущее количество фото: \(presenter.numberOfPhotos)")
        guard presenter.numberOfPhotos > 0 else {
             print("Нет данных для отображения")
             return
         }
        
        tableView.performBatchUpdates {
            let oldCount = tableView.numberOfRows(inSection: 0)
            let newCount = presenter.numberOfPhotos
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
                print("Анимация обновления завершена")
            }
        }
    
    func showLoading() {
        print("[ImagesListViewController]: Показать индикатор загрузки")
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        print("[ImagesListViewController]: Скрыть индикатор загрузки")
        UIBlockingProgressHUD.dismiss()
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        print("[ImagesListViewController]: Обновление строк \(indexPaths)")
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func getIndexPath(for cell: ImagesListCell) -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
    
    func showSingleImage(for photo: Photo) {
        print("[ImagesListViewController]: Показать детали фото \(photo.id)")
        performSegue(withIdentifier: "ShowSingleImage", sender: photo)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage",
           let viewController = segue.destination as? SingleImageViewController,
           let photo = sender as? Photo {
            print("[ImagesListViewController]: Подготовка перехода к деталям фото")
            viewController.fullImageURL = URL(string: photo.largeImageURL)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UITableViewDataSource & Delegate
extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfPhotos
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("[ImagesListViewController]: Ошибка создания ячейки ImagesListCell")
            return UITableViewCell()
        }
        imageListCell.delegate = self
        presenter.configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.heightForRow(at: indexPath, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.willDisplayCell(at: indexPath)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        print("[ImagesListViewController]: Обработка нажатия лайка в ячейке")
        presenter.changeLike(for: cell)
    }
}
