//
//  ViewController.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import UIKit
import Kingfisher

protocol MainListViewProtocol: class {
    func getNewRepos(reposViewData: [RepoViewData])
    func getNewUsers(usersViewData: [UserViewData])
}


class MainListViewController: UITableViewController, MainListViewProtocol {
    var presenter: MainListPresenterProtocol = MainListPresenter(manager: GithubManager())
    
    private var repositoriesViewData = [RepoViewData]()
    private var usersViewData = [UserViewData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.prefetchDataSource = self
        
        self.presenter.attachView(view: self)
        
        self.presenter.fetchNext(type: .Repo)
        self.presenter.fetchNext(type: .User)
    }
    
    func getNewRepos(reposViewData: [RepoViewData]) {
        self.repositoriesViewData += reposViewData
        ///TODO: increase perfomance - reload only needed cells
        self.tableView.reloadData()
    }
    
    func getNewUsers(usersViewData: [UserViewData]) {
        self.usersViewData += usersViewData
        ///TODO: increase perfomance - reload only needed cells
        self.tableView.reloadData()
    }
    
}


extension MainListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let loadingCells = 50
        return repositoriesViewData.count + usersViewData.count + loadingCells
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let loadedItemsCount = repositoriesViewData.count + usersViewData.count
        
        if (indexPath.row >= loadedItemsCount) {
            return loadingCell(in: tableView, for: indexPath)
        }
        let cellType = DataType.init(rawValue: indexPath.row % 2)!
        
        let index = indexPath.row / 2
        
        switch cellType {
        case DataType.Repo:
            if index >= repositoriesViewData.count {
                return loadingCell(in: tableView, for: indexPath)
            }
            return repoCell(in: tableView, for: indexPath)
            
        case DataType.User:
            if index >= usersViewData.count {
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
                self.presenter.fetchNext(type: type)
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
        cell.configure(viewData: usersViewData[index])
        return cell
    }
    
    private func repoCell(in tableView: UITableView, for indexPath: IndexPath) -> RepoCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RepoCell.rawValue, for: indexPath) as! RepoCell
        let index = indexPath.row / 2
        cell.configure(viewData: repositoriesViewData[index])
        return cell
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        let index = indexPath.row / 2
        let cellType = DataType.init(rawValue: indexPath.row % 2)!
        
        if cellType == .Repo && index >= repositoriesViewData.count {
            return true
        }
        else if cellType == .User && index >= usersViewData.count {
            return true
        }
        else {
            return indexPath.row >= repositoriesViewData.count + usersViewData.count
        }
    }
}

