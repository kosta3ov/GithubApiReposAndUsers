//
//  GithubReposAndUsersTests.swift
//  GithubReposAndUsersTests
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import GithubReposAndUsers

class RegexTests: XCTestCase {
    func testRegexLinkDetection() {
        let link = "<https://api.github.com/repositories?per_page=10&since=369>; rel=\"next\", <https://api.github.com/repositories{?since}>; rel=\"first\""
        
        let headers = LinkHeader.parseLinks(from: link)
        
        XCTAssert(headers[.next] == "https://api.github.com/repositories?per_page=10&since=369" , "Next link has not detected how it is needed")
        XCTAssert(headers[.first] == "https://api.github.com/repositories{?since}", "First link has not detected how it is needed")
        XCTAssert(headers[.last] == nil, "Last link should not be detected")
        XCTAssert(headers[.prev] == nil, "Prev link should not be detected")
    }
    
    func testAbsenceRegexLinkDetection() {
        let link = "Not a link"
        let headers = LinkHeader.parseLinks(from: link)
        XCTAssert(headers.count == 0, "Found links in NON-link string!!!")
    }
    
    
}

class NetworkLayerTests: XCTestCase {
    
    let bundle = Bundle.init(for: NetworkLayerTests.self)
    
    override func setUp() {
        /// stub for /repositories
        stub(condition: { (request) -> Bool in
            return request.url!.path == "/repositories"
        }) { (request) -> OHHTTPStubsResponse in
            
            let path = self.bundle.path(forResource: "repositories", ofType: "json")!
            
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Link":"<https://api.github.com/repositories?since=369>; rel=\"next\", <https://api.github.com/repositories{?since}>; rel=\"first\""])
        }
        
        /// stub for /users
        stub(condition: { (request) -> Bool in
            return request.url!.path == "/users"
        }) { (request) -> OHHTTPStubsResponse in
            let path = self.bundle.path(forResource: "users", ofType: "json")!
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Link":"<https://api.github.com/users?since=46>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""])
        }
        
        /// stub for /users/*
        stub(condition: { (request) -> Bool in
            let path = request.url!.path
            return path.starts(with: "/users/")
            
        }) { (request) -> OHHTTPStubsResponse in
            let path = self.bundle.path(forResource: "user1", ofType: "json")!
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
        }
        
        /// stub for /repos/
        stub(condition: { (request) -> Bool in
            let path = request.url!.path
            return path.starts(with: "/repos/")
        }) { (request) -> OHHTTPStubsResponse in
            let path = self.bundle.path(forResource: "repo1", ofType: "json")!
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
        }
    }
    
    func testPresenter() {
        let view = MainListView()
        let manager = GithubManager(userService: UserService(), repoService: RepoService())
        let presenter = MainListPresenter(manager: manager)
        presenter.attachView(view: view)
        
        let expectation1 = XCTestExpectation(description: "Download Mocked Data")
        let expectation2 = XCTestExpectation(description: "Download Mocked Data")
        
        view.getNewUsersViewData = { (usersViewData) in
            view.viewDataStorage.addNewUsers(usersViewData: usersViewData)
            expectation1.fulfill()
        }
        
        view.getNewReposViewData = { (newReposViewData) in
            view.viewDataStorage.addNewRepos(reposViewData: newReposViewData)
            expectation2.fulfill()
        }
        
        presenter.fetchNextRepositories(completion: view.getNewReposViewData!)
        presenter.fetchNextUsers(completion: view.getNewUsersViewData!)
        
        wait(for: [expectation1, expectation2], timeout: 2)
        
        XCTAssert(view.viewDataStorage.allViewDataCount > 0)
    }
    
}
