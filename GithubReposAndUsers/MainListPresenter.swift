//
//  File.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation

enum DataType: Int {
    case Repo = 0
    case User = 1
}

struct RepoViewData {
    let name: String
    let description: String
    
    let forks: Int
    let watchers: Int
    
    init(repo: Repo) {
        self.name = repo.name
        self.description = repo.description
        self.forks = repo.forks
        self.watchers = repo.watchers
    }
}

struct UserViewData {
    let name: String
    let avatarURL: URL
    let following: Int
    let followers: Int
    
    init(user: User) {
        self.name = user.name
        self.avatarURL = user.avatarURL
        self.following = user.following
        self.followers = user.followers
    }
}

protocol MainListViewProtocol: class {
    func showErrorMessage(message: String)
    var viewDataStorage: ViewDataStorageProtocol {get}
    
    var getNewUsersViewData: (([UserViewData]) -> Void)? { get set }
    var getNewReposViewData: (([RepoViewData]) -> Void)? { get set }
}


protocol MainListPresenterProtocol {
    func attachView(view: MainListViewProtocol)
    func detachView()
    func fetchNextRepositories(completion: @escaping ([RepoViewData]) -> Void)
    func fetchNextUsers(completion: @escaping ([UserViewData]) -> Void)
}


class MainListPresenter: MainListPresenterProtocol {
    private var githubManager: GithubManagerProtocol
    weak private var mainListView: MainListViewProtocol?
    
    init(manager: GithubManagerProtocol) {
        self.githubManager = manager
        self.githubManager.setErrorHandler { (err) in
            DispatchQueue.main.async {
                switch err {
                case .badRequest(let code, let message):
                    self.mainListView?.showErrorMessage(message: "\(code) \(message)")
                case .unprocessableEntity(let code, let message):
                    self.mainListView?.showErrorMessage(message: "\(code) \(message)")
                case .forbidden(let code, let message):
                    self.mainListView?.showErrorMessage(message: "\(code) \(message)")
                default:
                    self.mainListView?.showErrorMessage(message: "undefined error")
                }
            }
        }
    }
    
    func attachView(view: MainListViewProtocol) {
        self.mainListView = view
    }
    
    func detachView() {
        self.mainListView = nil
    }
    
    
    func fetchNextRepositories(completion: @escaping ([RepoViewData]) -> Void) {
        self.githubManager.fetchRepos { (repos) in
            let reposViewData = repos.map { RepoViewData(repo:$0) }
            DispatchQueue.main.async {
                completion(reposViewData)
            }
        }
    }
    
    func fetchNextUsers(completion: @escaping ([UserViewData]) -> Void) {
        self.githubManager.fetchUsers { (users) in
            let usersViewData = users.map { UserViewData(user:$0) }
        
            DispatchQueue.main.async {
                completion(usersViewData)
            }
        }
    }
    
}
