//
//  TestClasses.swift
//  GithubReposAndUsersTests
//
//  Created by Константин Трехперстов on 30.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation
@testable import GithubReposAndUsers

class MainListView: MainListViewProtocol {
    var getNewUsersViewData: (([UserViewData]) -> Void)?
    
    var getNewReposViewData: (([RepoViewData]) -> Void)?
    
    var viewDataStorage: ViewDataStorageProtocol = MainListViewDataStorage()
    
    func showErrorMessage(message: String) {
        assert(message.count > 0, "Got empty message")
    }
}


