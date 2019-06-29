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


protocol MainListPresenterProtocol {
    func attachView(view: MainListViewProtocol)
    func detachView()
    func fetchNext(type: DataType)
}


class MainListPresenter: MainListPresenterProtocol {
    private var githubManager: GithubManagerProtocol
    weak private var mainListView: MainListViewProtocol?
    
    init(manager: GithubManagerProtocol) {
        self.githubManager = manager
    }
    
    func attachView(view: MainListViewProtocol) {
        self.mainListView = view
    }
    
    func detachView() {
        self.mainListView = nil
    }
    
    func fetchNext(type: DataType) {
        switch type {
        case .Repo:
            self.fetchNextRepositories()
        case .User:
            self.fetchNextUsers()
        }
    }
    
    private func fetchNextRepositories() {
        self.githubManager.fetchRepos { (repos) in
            let reposViewData = repos.map { RepoViewData(repo:$0) }
            
            DispatchQueue.main.async {
                self.mainListView?.getNewRepos(reposViewData: reposViewData)
            }
        }
    }
    
    private func fetchNextUsers() {
        self.githubManager.fetchUsers { (users) in
            let userViewData = users.map { UserViewData(user:$0) }
            
            DispatchQueue.main.async {
                self.mainListView?.getNewUsers(usersViewData: userViewData)
            }
        }
    }
    
}
