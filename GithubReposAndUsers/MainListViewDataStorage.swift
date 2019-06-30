//
//  MainListViewModel.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 30.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation

protocol ViewDataStorageProtocol {
    func addNewRepos(reposViewData: [RepoViewData])
    func addNewUsers(usersViewData: [UserViewData])
    
    func getUserViewData(index: Int) -> UserViewData
    func getRepoViewData(index: Int) -> RepoViewData
    
    var reposViewDataCount: Int {get}
    var usersViewDataCount: Int {get}
    var allViewDataCount: Int {get}
}

class MainListViewDataStorage: ViewDataStorageProtocol {
    private var repositoriesViewData = [RepoViewData]()
    private var usersViewData = [UserViewData]()
    
    func addNewRepos(reposViewData: [RepoViewData]) {
        self.repositoriesViewData += reposViewData
    }
    
    func addNewUsers(usersViewData: [UserViewData]) {
        self.usersViewData += usersViewData
    }
    
    func getUserViewData(index: Int) -> UserViewData {
        assert(index < usersViewDataCount, "wrong index")
        return usersViewData[index]
    }
    func getRepoViewData(index: Int) -> RepoViewData {
        assert(index < reposViewDataCount, "wrong index")
        return repositoriesViewData[index]
    }
    
    var reposViewDataCount: Int {
        return repositoriesViewData.count
    }
    
    var usersViewDataCount: Int {
        return usersViewData.count
    }
    
    var allViewDataCount: Int {
        return usersViewDataCount + reposViewDataCount
    }
}
