//
//  ViewController.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import UIKit
import Kingfisher

class MainListViewController: UITableViewController, MainListViewProtocol {
    var viewDataStorage: ViewDataStorageProtocol = MainListViewDataStorage()
    
    var presenter: MainListPresenterProtocol = {
        let manager = GithubManager(userService: UserService(), repoService: RepoService())
        return MainListPresenter(manager: manager)
    }()
    
    var getNewUsersViewData: (([UserViewData]) -> Void)?
    var getNewReposViewData: (([RepoViewData]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.prefetchDataSource = self
        
        self.presenter.attachView(view: self)
        
        self.getNewReposViewData = { [weak self] (reposViewData) in
            self?.viewDataStorage.addNewRepos(reposViewData: reposViewData)
            ///TODO: increase perfomance - reload only needed cells
            self?.tableView.reloadData()
        }
        
        self.getNewUsersViewData = { [weak self] (usersViewData) in
            self?.viewDataStorage.addNewUsers(usersViewData: usersViewData)
            ///TODO: increase perfomance - reload only needed cells
            self?.tableView.reloadData()
        }
        
        self.presenter.fetchNextRepositories(completion: self.getNewReposViewData!)
        self.presenter.fetchNextUsers(completion: self.getNewUsersViewData!)
        
    }
    
    func showErrorMessage(message: String) {
        let alert = UIAlertController.init(title: "Error has occured", message: message, preferredStyle: .alert)
        let dismiss = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true)
    }
    
}


extension MainListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let loadingCells = 50
        return viewDataStorage.allViewDataCount + loadingCells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let loadedItemsCount = viewDataStorage.allViewDataCount
        
        if (indexPath.row >= loadedItemsCount) {
            return loadingCell(in: tableView, for: indexPath)
        }
        let cellType = DataType.init(rawValue: indexPath.row % 2)!
        
        let index = indexPath.row / 2
        
        switch cellType {
        case DataType.Repo:
            if index >= viewDataStorage.reposViewDataCount {
                return loadingCell(in: tableView, for: indexPath)
            }
            return repoCell(in: tableView, for: indexPath)
            
        case DataType.User:
            if index >= viewDataStorage.usersViewDataCount {
                return loadingCell(in: tableView, for: indexPath)
            }
            return userCell(in: tableView, for: indexPath)
        }
    }
}


extension MainListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let loadingCellsIndexPaths = indexPaths.filter(isLoadingCell(for:))
        
        if loadingCellsIndexPaths.count > 0 {
            let loadingCellsTypes = Set(loadingCellsIndexPaths.map { DataType.init(rawValue: $0.row % 2)! })
            for type in loadingCellsTypes {
                switch type {
                case .Repo:
                    self.presenter.fetchNextRepositories(completion: self.getNewReposViewData!)
                case .User:
                    self.presenter.fetchNextUsers(completion: self.getNewUsersViewData!)
                }
                
                
            }
        }
    }
}


private extension MainListViewController {
    private func loadingCell(in tableView: UITableView, for indexPath: IndexPath) -> LoadingCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.LoadingCell.rawValue, for: indexPath) as! LoadingCell
        cell.loadingIndicator.startAnimating()
        return cell
    }
    
    private func userCell(in tableView: UITableView, for indexPath: IndexPath) -> UserCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.UserCell.rawValue, for: indexPath) as! UserCell
        let index = indexPath.row / 2
        cell.configure(viewData: viewDataStorage.getUserViewData(index: index))
        return cell
    }
    
    private func repoCell(in tableView: UITableView, for indexPath: IndexPath) -> RepoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RepoCell.rawValue, for: indexPath) as! RepoCell
        let index = indexPath.row / 2
        cell.configure(viewData: viewDataStorage.getRepoViewData(index: index))
        return cell
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        let index = indexPath.row / 2
        let cellType = DataType.init(rawValue: indexPath.row % 2)!
        
        if cellType == .Repo && index >= viewDataStorage.reposViewDataCount {
            return true
        }
        else if cellType == .User && index >= viewDataStorage.usersViewDataCount {
            return true
        }
        else {
            return indexPath.row >= viewDataStorage.allViewDataCount
        }
    }
}

