//
//  GithubReposAndUsersUITests.swift
//  GithubReposAndUsersUITests
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import XCTest
import SBTUITestTunnel
@testable import GithubReposAndUsers

class GithubReposAndUsersUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        app.launchTunnel(withOptions: [SBTUITunneledApplicationLaunchOptionResetFilesystem])
        
        let matchRepositories = SBTRequestMatch(url: "github.com/repositories")
        let matchUsers = SBTRequestMatch(url: "github.com/users")
        let matchRepo = SBTRequestMatch(url: "github.com/repos/.*")
        let matchUser = SBTRequestMatch(url: "github.com/users/.*")
        
        app.stubRequests(matching: matchRepositories, response: SBTStubResponse(fileNamed: "repositories.json", headers: nil, returnCode: 200, responseTime: 0))
        app.stubRequests(matching: matchUsers, response: SBTStubResponse(fileNamed: "users.json", headers: nil, returnCode: 200, responseTime: 0))
        app.stubRequests(matching: matchRepo, response: SBTStubResponse(fileNamed: "repo1.json", headers: nil, returnCode: 200, responseTime: 0))
        app.stubRequests(matching: matchUser, response: SBTStubResponse(fileNamed: "user1.json", headers: nil, returnCode: 200, responseTime: 0))
        
    }


    func testExample() {
        
    }

}
