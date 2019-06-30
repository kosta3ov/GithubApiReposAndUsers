//
//  RepoService.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Repo: Codable {
    let name: String
    let description: String
    
    let watchers: Int
    let forks: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case watchers
        case forks
    }
}

final class RepoService: FetchServiceProtocol {
    typealias Item = Repo
    
    static let baseURL = "https://api.github.com/repositories"
    
    var session: URLSession = URLSession.shared
    
    var status: ServiceStatus = .ready

    var onCompletion: (([Repo]) -> Void)?
    var onError: ((ClientError) -> Void)?
    var onLink: (([LinkHeader:String]) -> Void)?
    
}
