//
//  UserService.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 28.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct User: Codable {
    let name: String
    let avatarURL: URL
    
    let following: Int
    let followers: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatarURL = "avatar_url"
        case following
        case followers
    }
}

final class UserService: FetchServiceProtocol {
    typealias Item = User

    static let baseURL = "https://api.github.com/users"
    
    var status: ServiceStatus = .ready
    
    var onCompletion: (([User]) -> Void)?
    var onError: ((ClientError) -> Void)?
    var onLink: (([LinkHeader : String]) -> Void)?
}

