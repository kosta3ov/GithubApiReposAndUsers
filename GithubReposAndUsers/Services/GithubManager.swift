//
//  GithubManager.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import Foundation
import RxSwift

enum ClientError: Error {
    static let badRequestCode = 400
    static let unprocessableEntityCode = 422
    
    case badRequest(code: Int, message: String)
    case unprocessableEntity(code: Int, message: String)
    case undefined
}

enum LinkHeader: String {
    case next
    case last
    case first
    case prev
    
    static private let regexPattern = "<(.+?)>;\\srel=\"(.+?)\""

    
    static private let regex = {
        try! NSRegularExpression(pattern: LinkHeader.regexPattern, options: .caseInsensitive)
    }()
    
    
    static func parseLinks(from str: String) -> [LinkHeader:String]  {
        var links = [LinkHeader:String]()
        let linkMatchPosition = 1
        let relMatchPosition = 2
        
        let range = NSRange(str.startIndex ..< str.endIndex, in: str)
        
        LinkHeader.regex.enumerateMatches(in: str, options: [], range: range) { (match, _, _) in
            if let linkNSRange = match?.range(at: linkMatchPosition),
                let relNSRange = match?.range(at: relMatchPosition),
                let linkRange = Range(linkNSRange, in: str),
                let relRange = Range(relNSRange, in: str) {
                
                let link = String(str[linkRange])
                let rel = String(str[relRange])
                
                if let enumValue = LinkHeader.init(rawValue: rel) {
                    links[enumValue] = link
                }
            }
        }
        
        return links
    }
}

struct FetchStatus {
    var nextReposURL = RepoService.baseURL
    var nextUsersURL = UserService.baseURL
}


protocol GithubManagerProtocol {
    func fetchRepos(process: @escaping ([Repo]) -> Void)
    func fetchUsers(process: @escaping ([User]) -> Void)
}


final class GithubManager: GithubManagerProtocol {
    private var userService = UserService()
    private var repoService = RepoService()
    
    private var status = FetchStatus()
    
    static func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("token 051d6b91b3d2dc8e645cebe2c81d740b9d1a4ba6", forHTTPHeaderField: "Authorization")
        return request
    }
    
    static func getLink(from response: HTTPURLResponse) -> String? {
        let linkKey = "Link"
        
        guard let link = response.allHeaderFields[linkKey] as? String else {
            return nil
        }
        
        return link
    }
    
    static func getError(from response: HTTPURLResponse, data: Data) -> ClientError {
        let messageKey = "message"
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDict = json as? [String: Any],
            let message = jsonDict[messageKey] as? String
            else {
                return .undefined
        }
        
        switch response.statusCode {
            case ClientError.badRequestCode:
                return .badRequest(code: ClientError.badRequestCode, message: message)
            case ClientError.unprocessableEntityCode:
                return .unprocessableEntity(code: ClientError.unprocessableEntityCode, message: message)
            default:
                return .undefined
        }
    }
    
    
    func fetchRepos(process: @escaping ([Repo]) -> Void) {
        self.repoService.onCompletion = process
        
        if case .ready = self.repoService.status {
            self.repoService.status = .loading
            self.repoService.getObjects(url: status.nextReposURL)
        }
    }
    
    func fetchUsers(process: @escaping ([User]) -> Void) {
        self.userService.onCompletion = process
        if case .ready = self.userService.status {
            self.userService.status = .loading
            self.userService.getObjects(url: status.nextUsersURL)
        }   
    }
    
    
    init() {
        
        let errorHandler = { (clientErr: ClientError) in
            
        }
        
        self.userService.onError = errorHandler
        self.repoService.onError = errorHandler
        
        
        self.userService.onLink = { links in
            if let next = links[.next] {
                self.status.nextUsersURL = next
            }
        }
        
        self.repoService.onLink = { links in
            if let next = links[.next] {
                self.status.nextReposURL = next
            }
        }
    }

}

